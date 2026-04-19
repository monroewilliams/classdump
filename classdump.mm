//
//  main.m
//  classdump
//
//  Created by Monroe Williams on 4/18/26.
//

#import <Foundation/Foundation.h>

#include <objc/objc-class.h>
#include <iostream>
#include <string.h>
#include <list>
#include <format>
#include <fnmatch.h>
#include <dlfcn.h>

std::string join(const std::list<std::string> list, std::string_view sep) {
    std::string result;
    bool first = true;
    for (const auto &s : list) {
        if (!first) result += sep;
        result += s;
        first = false;
    }
    return result;
}

bool gMethodAddresses = false;

// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
std::string mapTypeEncoding(std::string_view s) {
    switch(s[0]) {
        case 'c': return "char";
        case 'i': return "int";
        case 's': return "short";
        case 'l': return "long";
        case 'q': return "long"; // The docs have this as "long long"
        case 'C': return "unsigned char";
        case 'I': return "unsigned int";
        case 'S': return "unsigned short";
        case 'L': return "unsigned long";
        case 'Q': return "unsigned long"; // The docs have this as "unsigned long long"
        case 'f': return "float";
        case 'd': return "double";
        case 'B': return "bool";
        case 'v': return "void";
        case '*': return "char *";
        case '#': return "Class";
        case ':': return "SEL";
        //[array type] An array
        //{name=type...} A structure
        //(name=type...) A union
        case '{':
        {
            auto remainder = s.substr(1);
            auto equalsPos = remainder.find('=', 1);
            if (equalsPos != std::string::npos) {
                return std::string(remainder.substr(0, equalsPos));
            }
        }
        break;
        //bnum A bit field of num bits
        // bitfieldTypeEncoding will return a non-empty string for this case
        case 'b': return "unsigned";
        // ^type A pointer to type
        case '^': 
            return std::format("{}*", mapTypeEncoding(s.substr(1)));
        break;
        //? An unknown type (among other things, this code is used for function pointers)
        case '?': 
            return "<unknown>";
        break;
        case '@': 
            if (s.size() == 1) {
                return "id";
            }
            return std::format("{}*", mapTypeEncoding(s.substr(1)));
        break;
        case '"':
            return std::string(s.substr(1, s.size() - 2));
        break; 
        default: break;
    }
    return std::string(s);
}

std::string bitfieldTypeEncoding(std::string_view s) {
    switch(s[0]) {
        case 'b': 
            return std::format(" : {}", s.substr(1));
        default: break;
    }
    return "";
}

void dumpIvars(Ivar *list, int count, std::string_view prefix = "    ") {
    for (int i = 0; i < count; i++) {
        const char * name = ivar_getName(list[i]); 
        const char * typeEncoding = ivar_getTypeEncoding(list[i]); 
        // We're going to assume the array is in layout order, but will put the offset in a comment.
        ptrdiff_t offset = ivar_getOffset(list[i]);
        std::cout << std::format("{}{} {}{}; // offset {}", prefix, mapTypeEncoding(typeEncoding), name, bitfieldTypeEncoding(typeEncoding), offset) << std::endl;
    }
}

// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW1
void dumpProperties(objc_property_t *list, int count, id instance = nil, std::string_view prefix = "") {
    for (int i = 0; i < count; i++) {
        const char * name = property_getName(list[i]); 
        unsigned int attributeCount = 0;
        objc_property_attribute_t * attributeList = property_copyAttributeList(list[i], &attributeCount);
        std::string type;
        std::list<std::string> attributes; 
        if (instance != nil) {
            attributes.push_back("class");
        }
        if (attributeList != nil) {
            for (int j = 0; j < attributeCount; j++) {
                std::string name(attributeList[j].name);
                std::string value(attributeList[j].value);
                switch(name[0]) {
                    case 'R': attributes.push_back("readonly"); break;
                    case 'C': attributes.push_back("copy"); break;
                    case '&': attributes.push_back("retain"); break;
                    case 'N': attributes.push_back("nonatomic"); break;
                    case 'G': attributes.push_back(std::format("getter={}", value)); break;
                    case 'S': attributes.push_back(std::format("setter={}", value)); break;
                    case 'D': break; // The property is dynamic (@dynamic).
                    case 'W': attributes.push_back("weak"); break;
                    case 'P': break; // The property is eligible for garbage collection.
                    case 't': break; // t<encoding>   Specifies the type using old-style encoding.
                    case 'T': type = mapTypeEncoding(value); break;
                    default: break;
                }
            }
        }
        std::string attributesString;
        if (attributes.size() > 0) {
            attributesString = std::format("({}) ", join(attributes, ", "));
        }
        std::cout << std::format("{}@property {}{} {};", prefix, attributesString, type, name) << std::endl;
        
        free(attributeList);
    }
}

// https://nshipster.com/type-encodings/
void dumpMethods(Method *list, int count, std::string_view prefix = "-") {
    for (int i = 0; i < count; i++) {
        Method m = list[i];
        std::string name(sel_getName(method_getName(m)));
        auto returnTypeBuf = method_copyReturnType(m);
        std::string returnType(returnTypeBuf);
        free(returnTypeBuf);
                
        std::list<std::string> args;
        auto argc = method_getNumberOfArguments(m);
        // Arguments 0 and 1 are _always_ the implicit self pointer and the method selector.
        // Skip those.
        for (int j = 2; j < argc; j++) {
            auto argTypeBuffer = method_copyArgumentType(m, j);
            args.push_back(std::string(argTypeBuffer));
            free(argTypeBuffer);
        }

        std::cout << std::format("{} ({})", prefix, mapTypeEncoding(returnType));
        // Interleave the arguments with the components of the selector name.
        std::list<std::string> argumentStrings;
        size_t len = name.size();
        size_t mark = name.find(':');
        int paramNumber = 0;
        if (mark == std::string::npos) {
            // Selector with no arguments. Just output it whole.
            argumentStrings.push_back(name);
        } else {
            // There's at least one argument. Interleave types.
            auto iter = args.begin();
            size_t start = 0;
            do {
                argumentStrings.push_back(std::format("{}({})param{}", name.substr(start, mark + 1 - start), mapTypeEncoding(*iter), paramNumber));
                start = mark + 1;
                mark = name.find(':', start);
                iter++;
                paramNumber++;
            } while (mark != std::string::npos);
        }
        std::cout << join(argumentStrings, " ") << ";";
        
        if (gMethodAddresses) {
            std::cout << "  // image lookup -v --address " << (void*)method_getImplementation(m);
        }
        std::cout << std::endl; 
    }
}

void dumpClass(Class c)
{
    if (c == nil) {
        std::cout << "Class pointer is nil" << std::endl;
    }

    unsigned int count = 0;
    Ivar *ivarList;
    objc_property_t *propertyList;
    Method *methodList;

    // Get the meta-class to extract class properties and methods
    Class mc = object_getClass(c);

    auto name = object_getClassName(c);
    std::cout << "@interface " << name;
    Class sc = class_getSuperclass(c);
    if (sc != nil) {
        name = object_getClassName(sc);
        if (name != nil) {
            std::cout << " : " << name;
        }
    }

    unsigned int protocolCount = 0;
    auto protocols = class_copyProtocolList(c, &protocolCount);
    if ( protocolCount > 0) {
        std::list<std::string> protocolList;
        for (int i = 0; i < protocolCount; i++) {
            protocolList.push_back(protocol_getName(protocols[i]));
        }
        std::cout << std::format(" <{}>", join(protocolList, ", "));
    }
    free(protocols);
    
    std::cout << " {" << std::endl;

    ivarList = class_copyIvarList(c, &count); 
    std::cout << "// Ivars (" << count << "):" << std::endl;
    dumpIvars(ivarList, count);
    free(ivarList);

    std::cout << "}" << std::endl;

    propertyList = class_copyPropertyList(c, &count); 
    std::cout << "// Properties (" << count << "):" << std::endl;
    dumpProperties(propertyList, count);
    free(propertyList);

    propertyList = class_copyPropertyList(c, &count); 
    std::cout << "// Class Properties (" << count << "):" << std::endl;
    dumpProperties(propertyList, count, c);
    free(propertyList);
    
    methodList = class_copyMethodList(c, &count); 
    std::cout << "// Methods (" << count << "):" << std::endl;
    dumpMethods(methodList, count);
    free(methodList);

    methodList = class_copyMethodList(mc, &count); 
    std::cout << "// Class Methods (" << count << "):" << std::endl;
    dumpMethods(methodList, count, "+");
    free(methodList);


//    ivarList = class_copyIvarList(mc, &count); 
//    std::cout << "// Class Ivars (" << count << "):" << std::endl;
//    dumpIvars(ivarList, count);
//    free(ivarList);

    std::cout << "@end " << std::endl;
    std::cout << std::endl;
}

void dumpClass(const char *className)
{
    std::cout << "// ================== " << std::endl;
    std::cout << "// " << className << std::endl;

    Class c = objc_getClass(className);
    dumpClass(c);
}

NSArray<Class> *classesMatching(const std::string_view &s) {
    NSMutableArray<Class> *result = NSMutableArray.array;
    int numClasses = 0, newNumClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    while (numClasses < newNumClasses) 
    {
        numClasses = newNumClasses;
        classes = (Class*)realloc(classes, sizeof(Class) * numClasses);
        newNumClasses = objc_getClassList(classes, numClasses);
    }

//    std::cout << "Total class count = " << numClasses << std::endl;
    for (int i = 0; i < numClasses; i++) 
    {
        Class c = classes[i];
        const char * name = object_getClassName(c);
        if (name != nil) {
            if (fnmatch(std::string(s).c_str(), name, 0) == 0) {
                [result addObject:c];
            }
        }
    }
    return result.copy;
}

void dumpClassesMatching(const std::string_view &s) {
    NSArray<Class> *classes = classesMatching(s);
    for (Class c in classes) {
        dumpClass(c);
    }
}

void listClassesMatching(const std::string_view &s) {
    // I would call classesMatching here, but some of the Class objects returned by objc_getClassList
    // cause a crash when they're added to an NSArray. 

    int numClasses = 0, newNumClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    while (numClasses < newNumClasses) 
    {
        numClasses = newNumClasses;
        classes = (Class*)realloc(classes, sizeof(Class) * numClasses);
        newNumClasses = objc_getClassList(classes, numClasses);
    }

    for (int i = 0; i < numClasses; i++) 
    {
        Class c = classes[i];
        const char * name = object_getClassName(c);
        if (name != nil) {
            if (fnmatch(std::string(s).c_str(), name, 0) == 0) {
                auto name = object_getClassName(c);
                std::cout << name << std::endl;
            }
        }
    }
}


int main(int argc, const char * argv[]) {

    bool list = false;
    for (int i = 1; i < argc; i++) {
        std::string arg(argv[i]);
        if (arg == "-l") {
            list = true;
            continue;
        }
        if (arg == "-L") {
            // The next argument should be the full path to a shared library. Load it.
            i++;
            if (i >= argc) continue;
            auto handle = dlopen(argv[i], RTLD_LAZY);
            continue;
        }
        if (arg == "-a") {
            gMethodAddresses = true;
            continue;
        }
        if (list) {
            listClassesMatching(arg);
        } else {
            dumpClassesMatching(arg);
        }
    }

    // Things you can do:
//    listClassesMatching("*");
//    listClassesMatching("*ScreenSaver*");
//    dumpClass("NSView");
//    dumpClass("ScreenSaverView");
//    dumpClass("ScreenSaverExtension");
//    dumpClass("ScreenSaverViewController");
//    dumpClass("ScreenSaverConfigurationViewController");
        
    return EXIT_SUCCESS;
}
