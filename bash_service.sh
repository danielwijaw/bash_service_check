#!/bin/bash
URL_FRONTEND="http://0.0.0.0"
URL_BACKEND="http://0.0.0.0:81"
URL_FRONTEND_DEVELOPMENT="http://0.0.0.0:84"
URL_BACKEND_DEVELOPMENT="http://0.0.0.0:85"
TOKEN_TELEGRAM="XXXXXXXXXX:XXXXXXXXXXXXXXX"
CHAT_ID_TELEGRAM="XXXXXXXXX"
URL_SEND_MESSAGE_TELEGRAM="https://api.telegram.org/bot$TOKEN_TELEGRAM/sendMessage?chat_id=$CHAT_ID_TELEGRAM"
CURRENTDATE=`date +"%Y-%m-%d_%T"`
STATUS_CODE=200

sendTelegram() {
        local messageText="$1"
        local urlTTelegram="$URL_SEND_MESSAGE_TELEGRAM"

        sendMessageTelegram=$(curl --get -d "text=$messageText" --write-out "%{http_code}\n" --silent --output /dev/null $urlTTelegram)
        echo "Send Message Telegram Status $sendMessageTelegram with message $messageText"
}

createLog() {
	local fileName="$1"
        fileName=${fileName/'http://'/''}
        touch "/home/$fileName.log"
}

removeLog() {
	local fileName="$1"
        fileName=${fileName/'http://'/''}
        rm "/home/$fileName.log"
}

checkExistFileLog(){
        local fileName="$1"
        fileName=${fileName/'http://'/''}
        messageSendTelegram="Service%20:%20$fileName%0AStatus%20:%20Alive%0ADate%20:%20$CURRENTDATE%0AHttpCode%20:%20$STATUS_CODE"

        if [ -f "/home/$fileName.log" ]; then
                removeLog $fileName | sendTelegram $messageSendTelegram
        fi
}

checkService() {
        local getUrl="$1"

        requestUrl=$(curl --write-out "%{http_code}\n" --silent --output /dev/null $getUrl)
        responseHttpCode=$(tail -n1 <<< "$requestUrl")
        messageSendTelegram="Service%20:%20$getUrl%0AStatus%20:%20Down%0ADate%20:%20$CURRENTDATE%0AHttpCode%20:%20$responseHttpCode"

        if [[ "$responseHttpCode" -ne $STATUS_CODE ]]
        then
            	echo "Service $getUrl is not alive ($responseHttpCode)" | sendTelegram $messageSendTelegram | createLog $getUrl
        else
            	echo "Service $getUrl is alive ($responseHttpCode)" | checkExistFileLog $getUrl
        fi
}

checkService $URL_FRONTEND
checkService $URL_BACKEND
checkService $URL_FRONTEND_DEVELOPMENT
checkService $URL_BACKEND_DEVELOPMENT
