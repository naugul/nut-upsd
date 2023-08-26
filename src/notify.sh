# UPS Info
BATT=$(upsc "${UPSNAME}" battery.charge)
LOAD=$(upsc "${UPSNAME}" ups.load)
STATUS=$(upsc "${UPSNAME}" ups.status)
if [ "${STATUS}" = "OL" ]; then wol "${MACADDRESS}"; fi
# Prepare email subject and body
SUBJECT="UPS Status Changed: ${STATUS}"
BODY=$(cat <<EOF
UPS: ${UPSNAME}
Description: ${UPSDESC}

Status: ${STATUS}
Load: ${LOAD}%%
Battery Charge: ${BATT}%%
EOF
)
echo "Sending email..."
printf "Content-Type: text/plain\r\nSubject: ${SUBJECT} \r\n\r\n${BODY}" | sendmail ${SENDTO}
echo "Done!"