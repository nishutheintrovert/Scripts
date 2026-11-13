#!/usr/bin/env bash

#	Author	: Nishikant Kanunje
#	Date	: 14/11/2026
#	Purpose	: Edits values

v2_file="com.wordsmobile.gunship/shared_prefs/com.wordsmobile.gunship.v2.playerprefs.xml"

if [[ ! -f "$v2_file" ]]; then
    echo "Error: XML file not found in ./com.wordsmobile.gunship/shared_prefs/"
    exit 1
fi

# Create fresh backup directly inside ./backup/
rm -rf backup
mkdir -p backup
cp com.wordsmobile.gunship/shared_prefs/* backup/

# Edit com.wordsmobile.gunship.v2.playerprefs.xml
sed -E -i '
    /pieceType/d
    /<\/map>/d
    s/(<int name="(daimond|coin)" value=")[^"]*(" \/>)/\1999999999\3/
    s/(<int name="bossLeftTime[0-2]" value=")[^"]*(" \/>)/\1999\2/
' "$v2_file"

{
    for ((i = 0; i <= 35; i++)); do
        printf '    <int name="pieceType%d" value="999" />\n' "$i"
    done
    printf '</map>\n'
} >>"$v2_file"

# Calculate timestamps
printf -v epoch13 "%.13s" "${EPOCHREALTIME/./}"
paidv1_time=$((epoch13 - 6769))
enemy_time=$((${epoch13:0:10} - 12))

# Generate paid_storage_sp.xml
cat <<EOF >"com.wordsmobile.gunship/shared_prefs/paid_storage_sp.xml"
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <long name="paidv1_creation_time" value="${paidv1_time}" />
    <long name="paidv2_creation_time" value="${epoch13}" />
    <string name="paidv2_id">221bb141-35d6-4272-8fff-fd2c0c31cbc3</string>
    <string name="paidv1_id">d2a1f35a-7ea9-4e82-94ac-4ada286f138c</string>
</map>
EOF

# Generate Gunship.xml
cat <<EOF >"com.wordsmobile.gunship/shared_prefs/Gunship.xml"
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <long name="enemyTime" value="${enemy_time}" />
    <int name="goldDouble" value="1" />
    <int name="gold_amounts" value="999999999" />
    <int name="maxEnemgy" value="90" />
    <int name="money_amounts" value="999999999" />
    <int name="isAdFree" value="1" />
    <long name="clockTime" value="77469" />
</map>
EOF
