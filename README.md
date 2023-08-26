# Network UPS Tools server + webNUT

Docker image for Network UPS Tools server and webNUT.
Based on the work done by:

https://github.com/upshift-docker/nut-upsd

https://github.com/teknologist/docker-webnut

## Usage

This image provides a UPS monitoring service with web monitoring (webNUT) (only tested with a serial based UPS -using a usb to serial converter-).
It also has the capability to send emails whenever there is a status change on the UPS, and will also send a Wake on Lan packet on this status changes to OL mode. (AC Back)

## Auto configuration via environment variables

This image supports customization via environment variables.

### UPS_NAME

*Default value*: `ups`

The name of the UPS.

### UPS_DESC

*Default value*: `UPS`

This allows you to set a brief description that upsd will provide to clients that ask for a list of connected equipment.

### UPS_DRIVER

*Default value*: `usbhid-ups`

This specifies which program will be monitoring this UPS.

### UPS_PORT

*Default value*: `auto`

This is the serial port where the UPS is connected.

### ADMIN_PASSWORD

*Default value*: `secret`

This is the password for the admin user.

### API_PASSWORD

*Default value*: `secret`

This is the password for the upsmon user [monitor], used for communication between upsmon and upsd processes.

### SHUTDOWN_CMD

*Default value*: `echo 'No shutdown command defined.''`

This is the command upsmon will run when the system needs to be brought down. The command will be run from inside the container.

### NOTIFY_MAIL

*Default value*: ''

This is the email address to which upsmon will send an alert upon status change -uses local postfix service-.

### MAC_ADDRESS

*Default value*: ''

This is the MAC Address to which a WoL Packet will be sent upon status change to OL -online-.

------------------------------------------------------

### DOCKER COMPOSE EXAMPLE

```
version: '3.3'
services:
    nut-upsd:
        container_name: nut-upsd
        ports:
            - '3493:3493'
            - '6543:6543'
        environment:
            - 'UPS_DRIVER=blazer_ser'
            - 'UPS_NAME=polaris'
            - 'UPS_DESC=Polaris TX 1000'
            - 'UPS_PORT=/dev/ttyUSB0'
            - 'NOTIFY_MAIL=mail@example.com'
            - 'MAC_ADDRESS=aa:bb:cc:dd:ee:ff'
        volumes:
            - 'nut-volume:/etc/nut/'
        devices:
            - /dev/ttyUSB0
        image: naugul/nut-upsd
        restart: unless-stopped
volumes:
  nut-volume:
```
