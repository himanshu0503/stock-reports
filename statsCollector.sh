#!/bin/bash

#Don't run for commits by Bot
git log -1 > lastCommitMessage
if grep -Fxq "Bot" lastCommitMessage
then
    echo "Exiting as the committer is a BOT"
    exit 0
else
    echo "Standard Commit"
    rm lastCommitMessage
fi

DATE=`date +%Y%m%d`

curl https://www.nseindia.com/live_market/dynaContent/live_analysis/oi_spurts/topPositiveOIChangeData.json > oi/$DATE.csv
curl https://nseindia.com/archives/equities/mto/MTO_`date +%d%m%Y`.DAT > delivery/$DATE.csv

#Parsing Delivery File Correctly
echo "Record Type,Sr No,Name of Security, Type of Security, Quantity Traded,Deliverable Quantity(gross across client level),% of Deliverable Quantity to Traded Quantity" > temp.csv
sed '1,4d' delivery/$DATE.csv >> temp.csv
mv temp.csv delivery/$DATE.csv

#Parsing OI File Correctly
echo "Symbol, LatestOI, PrevOI, OIChange, %OIChange, Volume, IsFO" > temp.csv
cat oi/$DATE.csv | jq -r '.data[] | [.symbol, .latestOI, .prevOI, .oiChange, .percOIchange, .volume, .isFO] | @csv' >> temp.csv
mv temp.csv oi/$DATE.csv

git config credential.helper 'cache --timeout=120'
git config user.email "<email>"
git config user.name "Bot"
git add .
git commit --allow-empty -m "Data for $DATE"
git push -q https://${REPORTS_PERSONAL_TOKEN}@github.com/himanshu0503test/stock-reports.git master
