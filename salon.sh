#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"
echo -e "\n~~ Welcome to Your Salon ~~\n"
echo -e "How can I help you today?\n"


MAIN_MENU() {
  # Print a message if anything goes wrong
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # Get the services list and print it
  GET_SERVICES=$($PSQL "SELECT * from services")
  if [[ -z $GET_SERVICES ]]
  then
    echo "Sorry, there are no services available at the moment."
  else
    echo -e "$GET_SERVICES" | while IFS='|' read ID SERVICE
    do
      echo -e "$ID) $SERVICE"
    done
  fi

  # Select a service
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED -lt 1 || $SERVICE_ID_SELECTED -gt 3 ]]
  then 
    MAIN_MENU "That service is not available. Do you need anything else?"
  else

    # Enter number and verify customer
    echo -e "\nPlease enter your phone number"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # If it doesn't exist, then insert it with the name
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nPlease enter your name"
      read CUSTOMER_NAME
      INSERT_INFO=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      # Get new customer_id once created
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    fi

    # Create appointment
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nWhat time would you like for your $SERVICE_NAME service, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  
  fi

}

MAIN_MENU