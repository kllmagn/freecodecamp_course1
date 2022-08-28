#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

counter=0
names=()
years=()
rounds=()
winners=()
opponents=()
winner_goals_=()
opponent_goals_=()
declare -A teams
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  ((counter = counter + 1));
  if [ $counter -eq 1 ]; then
    continue
  fi
  names+=("$winner" "$opponent")
  years+=("$year")
  rounds+=("$round")
  winners+=("$winner")
  opponents+=("$opponent")
  winner_goals_+=("$winner_goals")
  opponent_goals_+=("$opponent_goals")
done < games.csv
echo $($PSQL "TRUNCATE TABLE games, teams;")
for name in "${names[@]}"; do
  teams[$name]=0
done
for team in "${!teams[@]}"; do
  echo $($PSQL "INSERT INTO teams(name) VALUES ('$team');")
done
for ((i=0;i<${#years[@]};i++)); do
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='${winners[i]}';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='${opponents[i]}';")
  echo $($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES(${years[i]},'${rounds[i]}',$winner_id,$opponent_id,${winner_goals_[i]},${opponent_goals_[i]});")
done
