#!/bin/bash
#---------------------------------------------------------------------------------
#       Script name             :       GetLatestTballResults.sh
#---------------------------------------------------------------------------------
#	    Email			:		therewillbewolves@gmail.com
#       Created			:       24/07/2016
#       Description		:       Curl Thunderball results page and -
#						:		- insert record into mysql.
#---------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
# Variable Declaration and includes
# --------------------------------------------------------------------------------
url="https://www.national-lottery.co.uk/results/thunderball/draw-history/draw-details/"
lastId=$(mysql -u root -p"ThunderBall" -e "USE thunder_ball_db; SELECT draw_id FROM draw_archive ORDER BY draw_id DESC LIMIT 1;" | sed 's/[^0-9]*//g')
nextId=$((lastId + 1))
wget --directory-prefix=/home/ec2-user --output-document=results.html "${url}${nextId}"


rm -f date.txt id.txt numbers.txt results.html


#grep -A1 'header_draw_number' results.html > id.txt
#echo "$(tail -n +2 id.txt)" > id.txt
#id=$(cat id.txt | sed 's/[^0-9]*//g')

id=$(grep -A1 'header_draw_number' results.html | echo "$(tail -n +2 id.txt)" | echo "$(cat id.txt | sed 's/[^0-9]*//g')")

grep -A1 '<div id="section_header">' results.html > date.txt
echo "$(tail -n +2 date.txt)" > date.txt
date=$(cat date.txt | tail -c21 | head -c -6)

cat results.html | grep -i '<li class="normal' >> numbers.txt
cat results.html | grep -i '<li class="special special_first special_last">' >> numbers.txt
results=$(cat numbers.txt | sed 's/[^0-9]*//g')
numbers=($results)

values="${id}, '${date}', '${numbers[0]}','${numbers[1]}','${numbers[2]}','${numbers[3]}','${numbers[4]}','${numbers[5]}',"

function UpdateDB() {
mysql -u root -p"ThunderBall" -e "USE thunder_ball_db; INSERT INTO draw_archive (draw_id, date, first_ball, second_ball, third_ball, fourth_ball, fifth_ball, thunder_ball, wins, machine,ball_set) VALUES (${values});"
}

UpdateDB

