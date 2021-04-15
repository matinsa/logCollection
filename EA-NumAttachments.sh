#!/bin/bash

jamfProURL="https://jamfpro.acme.net:8443"
jamfProUser="apiuser-logcollection"
jamfProPass="apiuserpassword"

# use the right xpath for macOS version based on build - reference -> https://scriptingosx.com/2020/10/dealing-with-xpath-changes-in-big-sur/
xpath() {
    # the xpath tool changes in Big Sur 
    if [[ $(sw_vers -buildVersion) > "20A" ]]; then
        /usr/bin/xpath -e "$@"
    else
        /usr/bin/xpath "$@"
    fi
}

## Grab local serial number
mySerial=$( system_profiler SPHardwareDataType | grep Serial |  awk '{print $NF}' )

## Determine Jamf Pro Device ID
jamfProID=$( curl -k -u $jamfProUser:$jamfProPass $jamfProURL/JSSResource/computers/serialnumber/$mySerial/subset/general | xpath "//computer/general/id/text()" )

## API Lookup for how many attachments are attached to this device record
numAttachments=$( curl -u $jamfProUser:$jamfProPass $jamfProURL/JSSResource/computers/id/$jamfProID -X GET | xmllint -format - | xpath '/computer/purchasing/attachments' | grep "<id>" | wc -l | xargs )

## Echo results for EA
echo "<result>$numAttachments</result>"
