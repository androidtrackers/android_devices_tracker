today=$(date +%d.%m.%Y)

#Download latest list
wget -q https://jep-asset.akamaized.net/jio/jio-phone/Make-Models.pdf

#Download files
wget -q https://github.com/tabulapdf/tabula-java/releases/download/v1.0.2/tabula-1.0.2-jar-with-dependencies.jar

#Install csv2md
npm install -g csv2md

#Convert to CSV
java -jar tabula-1.0.2-jar-with-dependencies.jar -l -p all Make-Models.pdf > out.csv

#Optimizing
cat out.csv | perl -pe 's/\r(?!\n)/ /g' | sed -e 's|,|\n|2' | sed -e 's|,|\n|2' | sed 's/"//g' | sed -n '/Brand/!p' | sort -u | sed '1d' | sed '1 i\Brand,Model' > models.csv

#Convert to MD
csv2md models.csv > README.md

#Add header
cat << EOF >> head
# Smartphone devices list
Last sync is $today

EOF
cat head README.md > temp && mv temp README.md

#Diff
git diff | grep -P '^\+(?:(?!\+\+))|^-(?:(?!--))' | sed -n '/-/!p' | sed -n '/sync/!p'| cut -d + -f2 > changes

#Push
git config --global user.email "$gitmail"; git config --global user.name "$gituser"
git add README.md; git commit -m $today
git push -q https://$GIT_OAUTH_TOKEN_XFU@github.com/androidtrackers/android_devices_tracker.git HEAD:master
