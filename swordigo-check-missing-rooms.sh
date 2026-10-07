#!/usr/bin/env bash

echo "[*] Locating the latest Swordigo save file on device..."
LATEST_FILE=$(adb shell su -c 'ls -t /data/data/com.touchfoo.swordigo/files/Documents/*.gplayer | head -n 1' | tr -d '\r')

if [ -z "$LATEST_FILE" ]; then
    echo "[-] Error: Could not find any .gplayer files. Ensure phone is connected via ADB and rooted."
    exit 1
fi

echo "[*] Extracting $LATEST_FILE..."
adb exec-out su -c "cat '$LATEST_FILE'" >current_run_raw.gplayer

echo "[*] Decoding protobuf binary..."
protoc --decode_raw <current_run_raw.gplayer >current_run_decoded.txt

echo "[*] Parsing visited locations and flags..."
awk '/^  2 \{/{flag=1; next} /^\s*\}/{flag=0} flag && /1: "/ {split($0, a, "\""); print a[2]}' current_run_decoded.txt | sort | uniq >current_run_rooms.txt

echo "[*] Generating 100% reference baseline..."
cat <<'EOF' >100_percent_clean.txt
aeron
banditleader
beyond_graveyard
bossDoor
boulder
broadsword1
chest_chest
chest_chest1
chest_chest_left1
chest_chest_right1
chest_keychest
chest_obj1
chest_obj11
chest_obj13
chest_obj13#2
chest_obj13#3
chest_obj15
chest_obj16
chest_obj16#2
chest_obj17
chest_obj17#2
chest_obj18
chest_obj2
chest_obj3
chest_obj3#2
chest_obj4
chest_obj5
chest_obj5#2
chest_obj6
chest_obj7
chest_obj8
chest_obj9
corrupt_snort1
crypt1
cryptkey1
d1_key2
d1_key3
d1_key4
d1_lock1
d1_lock2
d1_lock3
d1_lock4
d2_key0
end_lock1
end_lock2
f_jail_p2_key
ff_destroyed
fire_part1
fire_part2
fire_part3
fire_part31
fire_part4
fire_part5
fire_partBoss
firep5_key
firstDoor
flor_key1
florennum_cave1
florennum_healerhouse
florennum_jail_boss
florennum_jail_part1
florennum_jail_part2
florennum_part1
florennum_shop
florennum_tower1
florennum_tower2
florennum_towertop
florennum_wall1
forest_cave0
forest_cave1
forest_cave2
forest_cave3
forest_cave4
forest_cave5
forest_part1
forest_part2
grass_house
grass_part1
grass_part2
grass_part3
grove_crypt1
grove_graveyard
grove_part1
grove_part2
grove_sacred
grover
has_portal
icecastle_bosskey
icecastle_key1
icecastle_part1
icecastle_part11
icecastle_part2
icecastle_part3
icecastle_part4
icecastle_part5
icecastle_partBoss
icecastlekey2
icekey2
icetrinket
iselon_shard_1
iselon_shard_2
iselon_shard_3
iselon_shard_4
key1
key11
key12
knightkilled
lock1
lowered
lowergrove_part1
magicarmor
magicsword_key
movieplayed
obj1
obj12
obj13#3
obj16#3
obj2#2
obj2#3
obj3
obj3#2
obj8
p3_key1
p3_lock1
plains_cave0
plains_caveFirst
plains_house1
plains_part1
plains_part2
plains_part3
plains_part4
plains_tower1
plains_woodkeep
plains_woodkeep2
plains_woodkeep3
plains_woodkeep_cellar
plains_woodkeep_entrance
portal_found
qt_dimension_trigger1
qt_dimension_trigger2
qt_quest01_find_master_obj11
qt_quest01_find_master_questTrigger2
qt_quest03_woodkeep_resurrectionTrigger
qt_quest03_woodkeep_trigger
qt_quest05_florennum_obj14
qt_quest05_florennum_trigger
qt_quest06_florennum_shard_knight1
qt_quest06_florennum_shard_knight1_text2
qt_quest071_fire_quest07_script
qt_quest072_ice_questtrigger
qt_quest09_assemble_master
qt_quest10_death_finalquesttrigger
qt_snowyboulder_quest
qt_vaseQuest_quest
raftActive
redshard
redsharddos
redshards
rocknomore
s1
s2
sack1
sackie
sackie1
sackiehere
sackiep3
sackofxp
secretshard1
shadowtrinket
shardo
shards
shardy1
sharod
snowy1_key1
snowy_cave1
snowy_cave2
snowy_part1
snowy_part2
snowy_part3
snowy_part4
specialkey
ssahrd1
sshard
sshard1
ssharddo
sshardie
sshardie_red
sshardiee
sshardies
sshardiesyel
sshardiesyy2
sshardo
sshardo1
sshardoo
sshardosyellows
sshards
ssharroddsafd
stonepile1_destroyed
summit
thecave_crypt1
thecave_crypt2
thecave_part1
thecave_part11
thecave_part12
thecave_part121
thecave_part13
thecave_part131
thecave_part132
thecave_part14
thecave_part141
thecave_part1411
thecave_part142
thecave_part1421
thecave_part15
thecave_part2
thecave_part21
thecave_part22
thecave_part23
thecave_part24
theend
theneedle
thisstone
tower
tower2_key1
town_elderhouse
town_healerhouse
town_herohouse
town_part1
town_secrethouse
town_shop
town_woods1
town_woods_end
treasure_chest_0
treasure_chest_left1_0
treasure_chest_right1_0
treasure_obj11_0
treasure_obj11_1
treasure_obj13#3_0
treasure_obj13_0
treasure_obj17#2_0
treasure_obj17_0
treasure_obj18_0
treasure_obj2_0
treasure_obj3_0
treasure_obj3_1
treasure_obj4_0
treasure_obj5#2_0
treasure_obj5_0
treasure_obj8_0
treasure_obj9_0
trinket1
wasteland_cave
wasteland_cave1
wasteland_cave_snowy
wasteland_house1
wasteland_part1
wasteland_part2
wasteland_part3
wasteland_part4
wasteland_town
wasteland_town_healerhouse
wasteland_town_secrethouse
wasteland_town_shop
we_p7_lock
we_p8_key
we_part5_lock
wlches1ss
worldsend_part1
worldsend_part2
worldsend_part3
worldsend_part4
worldsend_part5
worldsend_part6
worldsend_part7
worldsend_part8
worldsend_part9
worldsendkey_part5
xp1
xpsack
yellowshard
yellowshards
EOF

echo ""
echo "=================================================="
echo " MISSING ROOMS, CHESTS, & TRIGGERS                "
echo "=================================================="

# comm -23 outputs lines that only exist in the first file (the 100% completion list)
comm -23 100_percent_clean.txt current_run_rooms.txt

echo "=================================================="
echo ""
echo "[*] Cleaning up temporary files..."
rm current_run_raw.gplayer current_run_decoded.txt current_run_rooms.txt 100_percent_clean.txt
echo "[*] Analysis complete!"
