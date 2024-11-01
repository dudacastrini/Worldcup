#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Insert unique teams into the teams table
echo "Inserting unique teams..."
# Use a temporary array to track unique team names
declare -A teams

# Read games.csv to get unique team names
while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header line
  if [[ "$year" != "year" ]]; then
    teams["$winner"]=1
    teams["$opponent"]=1
  fi
done < games.csv

# Insert each unique team into the teams table
for name in "${!teams[@]}"; do
  echo "$($PSQL "INSERT INTO teams (name) VALUES ('$name') ON CONFLICT (name) DO NOTHING")"
done

# Now insert games into the games table
echo "Inserting games..."
while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header line
  if [[ "$year" != "year" ]]; then
    # Get the IDs of the winner and opponent teams
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")"
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")"

    # Insert game into the games table
    echo "$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)")"
  fi
done < games.csv

echo "Data insertion complete."
