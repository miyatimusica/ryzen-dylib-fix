#!/bin/zsh

# ==============================================================================
# ryzen-dylib-fix v3.1 - Master Runtime Patch (Optimizado)
# ==============================================================================

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "${CYAN}${BOLD}========================================================"
echo "   🚀 RYZEN-DYLIB-FIX: INSTALADOR OPTIMIZADO v3.1 PRO   "
echo "========================================================${NC}"
echo ""

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "${RED}❌ Este script solo puede ejecutarse en macOS.${NC}"
    exit 1
fi

INSTALL_DIR="/Library/Application Support/Ryzentosh"
AGENT_PLIST="$HOME/Library/LaunchAgents/com.ryzentosh.globalfix.plist"

echo "${BOLD}📁 [1/4] Preparando directorios del sistema...${NC}"
sudo mkdir -p "$INSTALL_DIR"

echo "${BOLD}⚙️ [2/4] Compilando ryzen_fix.dylib con optimización -O2 (x86_64)...${NC}"
TMP_SRC=$(mktemp /tmp/ryzen_fix_XXXXXX.m)

cat << 'INNER_EOF' > "$TMP_SRC"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@implementation NSData (RyzentoshGlobalFix)
- (const char *)_fastCStringContents:(BOOL)nullTerminated {
    return "AMD Radeon Graphics";
}
@end

@implementation NSProcessInfo (ChromiumRyzenFix)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        Method orig = class_getInstanceMethod(class, @selector(arguments));
        Method swiz = class_getInstanceMethod(class, @selector(ryzen_arguments));
        if (orig && swiz) method_exchangeImplementations(orig, swiz);
    });
}

- (NSArray<NSString *> *)ryzen_arguments {
    static NSArray<NSString *> *cachedArgs = nil;
    static dispatch_once_t argsToken;
    dispatch_once(&argsToken, ^{
        NSArray<NSString *> *originalArgs = [self ryzen_arguments];
        NSString *execPath = [[NSBundle mainBundle] executablePath].lowercaseString;
        BOOL isTargetApp = NO;
        if (execPath) {
            NSArray *apps = @[@"brave", @"chrome", @"edge", @"electron", @"code", @"discord", @"slack", @"spotify", @"vivaldi", @"opera", @"arc"];
            for (NSString *app in apps) {
                if ([execPath containsString:app]) { isTargetApp = YES; break; }
            }
        }
        if (isTargetApp && ![originalArgs containsObject:@"--use-gl=angle"]) {
            NSMutableArray *mArgs = [originalArgs mutableCopy];
            [mArgs addObjectsFromArray:@[@"--use-gl=angle", @"--use-angle=gl", @"--disable-features=SkiaGraphite,SkiaGraphiteDawn", @"--disable-gpu-sandbox"]];
            cachedArgs = [mArgs copy];
        } else {
            cachedArgs = originalArgs;
        }
    });
    return cachedArgs;
}
@end

__attribute__((constructor))
static void init_ryzen_master_fix(void) {
    setenv("ELECTRON_EXTRA_LAUNCH_ARGS", "--use-gl=angle --use-angle=gl --disable-features=SkiaGraphite,SkiaGraphiteDawn --disable-gpu-sandbox", 1);
}
INNER_EOF

sudo clang -O2 -dynamiclib -arch x86_64 -framework Foundation -framework CoreFoundation "$TMP_SRC" -o "$INSTALL_DIR/ryzen_fix.dylib"
sudo chmod 755 "$INSTALL_DIR/ryzen_fix.dylib"
rm -f "$TMP_SRC"

echo "${GREEN}✅ Librería compilada en $INSTALL_DIR/ryzen_fix.dylib${NC}\n"

echo "${BOLD}📦 [3/4] Configurando LaunchAgent para persistencia...${NC}"
mkdir -p "$HOME/Library/LaunchAgents"

cat << INNER_EOF > "$AGENT_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dylib">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ryzentosh.globalfix</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>-c</string>
        <string>launchctl setenv DYLD_INSERT_LIBRARIES "$INSTALL_DIR/ryzen_fix.dylib"</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
INNER_EOF

chmod 644 "$AGENT_PLIST"
launchctl setenv DYLD_INSERT_LIBRARIES "$INSTALL_DIR/ryzen_fix.dylib"
launchctl load -w "$AGENT_PLIST" 2>/dev/null || true

echo "${GREEN}✅ Variable DYLD_INSERT_LIBRARIES configurada.${NC}\n"

echo "${BOLD}🔒 [4/4] Limpiando atributos extendidos de cuarentena...${NC}"
if [ -d "/Applications/Native Instruments" ]; then
    sudo xattr -cr "/Applications/Native Instruments" 2>/dev/null || true
fi

echo "${GREEN}✅ Proceso finalizado exitosamente.${NC}\n"
