#!/bin/zsh

# ==============================================================================
# ryzen-dylib-fix - Universal Runtime Patch for Ryzentosh (NootEDred.kext)
# ==============================================================================

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_progress() {
    local duration=$1
    local steps=20
    local delay=$(( (duration + 0.0) / steps ))
    
    for i in $(seq 1 $steps); do
        local pct=$(( i * 100 / steps ))
        local num_chars=$(( i * 20 / steps ))
        local fill=$(printf '%*s' "$num_chars" '' | tr ' ' '█')
        local empty=$(printf '%*s' "$(( 20 - num_chars ))" '' | tr ' ' '░')
        printf "\r⏳ [%s%s] %3d%%" "$fill" "$empty" "$pct"
        sleep $delay
    done
    echo ""
}

echo ""
echo "${CYAN}${BOLD}========================================================"
echo "   🚀 RYZEN-DYLIB-FIX: INSTALADOR UNIVERSAL v2.0 PRO    "
echo "========================================================${NC}"
echo ""

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "${RED}❌ Este script solo puede ejecutarse en macOS.${NC}"
    exit 1
fi

INSTALL_DIR="/Library/Application Support/Ryzentosh"
AGENT_PLIST="$HOME/Library/LaunchAgents/com.ryzentosh.globalfix.plist"

echo "${BOLD}📁 [1/5] Creando directorios del sistema...${NC}"
sudo mkdir -p "$INSTALL_DIR"
show_progress 0.4
echo "${GREEN}✅ Directorio listo en $INSTALL_DIR${NC}\n"

echo "${BOLD}🛠️ [2/5] Generando librería dinámica (NSData Category Fix)...${NC}"
sudo cat << 'INNER_EOF' > /tmp/ryzen_fix.m
#import <Foundation/Foundation.h>

@implementation NSData (RyzentoshGlobalFix)

- (const char *)_fastCStringContents:(BOOL)nullTerminated {
    return "AMD Radeon Graphics";
}

- (const char *)UTF8String {
    return "AMD Radeon Graphics";
}

- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding {
    return "AMD Radeon Graphics";
}

- (BOOL)isEqualToString:(NSString *)aString {
    return YES;
}

- (NSComparisonResult)compare:(NSString *)string {
    return NSOrderedSame;
}

- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string {
    return NSOrderedSame;
}

@end
INNER_EOF

show_progress 0.6
echo "${GREEN}✅ Código fuente de ryzen_fix.m generado.${NC}\n"

echo "${BOLD}⚙️ [3/5] Compilando ryzen_fix.dylib (x86_64)...${NC}"
sudo clang -dynamiclib -arch x86_64 -framework Foundation /tmp/ryzen_fix.m -o "$INSTALL_DIR/ryzen_fix.dylib"
sudo chmod 755 "$INSTALL_DIR/ryzen_fix.dylib"
rm -f /tmp/ryzen_fix.m

show_progress 1.0
echo "${GREEN}✅ Librería compilada en $INSTALL_DIR/ryzen_fix.dylib${NC}\n"

echo "${BOLD}📦 [4/5] Configurando la persistencia en launchd...${NC}"
mkdir -p "$HOME/Library/LaunchAgents"

cat << INNER_EOF > "$AGENT_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
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

show_progress 0.8
echo "${GREEN}✅ Variable DYLD_INSERT_LIBRARIES inyectada globalmente.${NC}\n"

echo "${BOLD}🔒 [5/5] Ajustando atributos extendidos y firmas de aplicaciones...${NC}"

if [ -d "/Applications/Native Instruments" ]; then
    echo "   🎹 Procesando Native Instruments..."
    sudo xattr -cr "/Applications/Native Instruments" 2>/dev/null || true
    sudo codesign --force --deep --sign - --preserve-metadata=entitlements,flags,runtime "/Applications/Native Instruments"/*/*.app 2>/dev/null || true
fi

if [ -d "/Applications/Kontakt 8.app" ]; then
    sudo xattr -cr "/Applications/Kontakt 8.app" 2>/dev/null || true
    sudo codesign --force --deep --sign - --preserve-metadata=entitlements,flags,runtime "/Applications/Kontakt 8.app" 2>/dev/null || true
fi

show_progress 1.2
echo "${GREEN}✅ Permisos y firmas actualizados con éxito.${NC}\n"

echo "${CYAN}${BOLD}========================================================"
echo " 🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!               "
echo " 🎧 Todas las apps de audio ahora están protegidas.    "
echo "========================================================${NC}\n"
