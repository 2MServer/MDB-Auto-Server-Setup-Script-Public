#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#===============================================================================
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
# ░█▀█░█░█░▀█▀░█▀█░░░█▀▀░█▀▀░█▀▄░█░█░█▀▀░█▀▄░░░█▀▀░█▀▀░▀█▀░█░█░█▀█░░░░░░░░░░░░░░
# ░█▀█░█░█░░█░░█░█░░░▀▀█░█▀▀░█▀▄░▀▄▀░█▀▀░█▀▄░░░▀▀█░█▀▀░░█░░█░█░█▀▀░░░░░░░░░░░░░░
# ░▀░▀░▀▀▀░░▀░░▀▀▀░░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░░░▀▀▀░▀▀▀░░▀░░▀▀▀░▀░░░░░░░░░░░░░░░░
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
#===============================================================================
# TITLE           : Auto Server Setup
# PATH            : MDB-Auto-Server-Setup-Script-Public/mdb_auto_server_setup.sh
# FILENAME        : mdb_auto_server_setup.sh
# NAME            : mdb_auto_server_setup.sh
# VERSION         : 1.1.7
# DESCRIPTION     : Sets up a web server with DNS records, domain name, and SSL.
# CREATED         : MARCH 26 2025
# AUTHOR          : Matt Daniel Brown <dev@mattbrown.email>
#===============================================================================

# Exit on any error, unset variables, or pipe failures
set -euo pipefail

#-------------------------------------------------------------------------------
# Variable Declarations
#-------------------------------------------------------------------------------

# Unset variables to ensure a clean slate
unset SERVER_ROOT
unset DOMAIN_NAME
unset DNS_PROVIDER
unset API_KEY
unset API_SECRET
unset API_TOKEN
unset ZONE_ID

unset RESET
unset BOLD
unset GREEN
unset BLUE
unset CYAN
unset YELLOW
unset RED
unset DIM
unset ITALIC

# Define variables
SERVER_ROOT="/var/www/html"
DOMAIN_NAME=""
DNS_PROVIDER=""
API_KEY=""
API_SECRET=""
API_TOKEN=""
ZONE_ID=""

# ANSI Colors
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
RED="\033[31m"
YELLOW="$(printf '\033[33m')"
BOLD="$(printf '\033[1m')"
ITALIC="$(printf '\033[3m')"
DIM="$(printf '\033[2m')"
RESET="$(printf '\033[0m')"

#-------------------------------------------------------------------------------
# Function Definitions
#-------------------------------------------------------------------------------

#---[Informative & Logging Functions]-------------------------------------------

# @function ~ Print informative message
function print_message() {
	local MESSAGE_TEXT
	MESSAGE_TEXT="${1}"
	echo -e "\n${RESET}  ${ITALIC}${CYAN}(Info) ››  ${RESET}${DIM}${MESSAGE_TEXT}${RESET}\n\n"
}

# @function ~ Print success message
function print_success_message() {
	local SUCCESS_MESSAGE_TEXT
	SUCCESS_MESSAGE_TEXT="${1}"
	echo -e "\n ${BOLD}${GREEN} ✅  ${SUCCESS_MESSAGE_TEXT}${RESET}\n\n"
}

# @function ~ Print warning, caution, or issue message
function print_warning() {
	local WARNING_TEXT
	WARNING_TEXT="${1}"
	echo -e "\n ${ITALIC}${YELLOW} ⚠️  ${WARNING_TEXT}${RESET}\n\n"
}

# @function ~ Print error or problem message
function print_error() {
	local ERROR_TEXT
	ERROR_TEXT="${1}"
	echo -e "\n ${BOLD}${RED} 🛑  ${ERROR_TEXT}${RESET}\n"
}

#---[Utility Functions]---------------------------------------------------------

# @function ~ Ensure script runs as root
function check_root() {
	print_message "Checking for root access..."
	if [[ "${EUID}" -ne 0 ]]; then
		print_error "This script must be run as root (try again, using sudo)."
		exit 1
	else
		print_success_message "Script has root permissions."
	fi
}

# @function ~ Install dependencies for server and additional feature setup
function install_dependencies() {
	print_message "Updating and Installing required dependencies..."
	apt update -y && print_success_message "Updated packages."
	apt install -y nginx curl jq certbot python3-certbot-nginx && print_success_message "Installed dependencies."
}

#---[Server Feature Setup Functions]--------------------------------------------

# @function ~ Show user their selected choices before asking if user is done
function display_users_current_choices_and_selections() {
	echo -e " ${BOLD} --- CURRENT CHOICES AND SETTINGS --- ${RESET}"
	echo -e "  ${DIM}${BOLD}* DOMAIN NAME : ${RESET}${GREEN}${DOMAIN_NAME}  ${RESET}"
	echo -e "  ${DIM}${BOLD}* DNS PROVIDER: ${RESET}${GREEN}${DNS_PROVIDER} ${RESET}"
	if [[ "${DNS_PROVIDER}" == "Cloudflare" ]]; then
		echo -e "  ${DIM}${BOLD}* Cloudflare Zone ID  : ${RESET}${GREEN}${ZONE_ID}   ${RESET}"
		echo -e "  ${DIM}${BOLD}* API TOKEN           : ${RESET}${GREEN}(hidden)${RESET}"
	elif [[ "${DNS_PROVIDER}" == "GoDaddy" ]]; then
		echo -e "  ${DIM}${BOLD}* API KEY     : ${RESET}${GREEN}(hidden)${RESET}"
	elif [[ "${DNS_PROVIDER}" == "Namecheap" ]]; then
		echo -e "  ${DIM}${BOLD}* API SECRET  : ${RESET}${GREEN}(hidden)${RESET}"
	fi
}

# @function ~ Prompt user to continue with current config or to edit them
function ask_user_to_keep_or_change_current_configurations() {
	unset SUBMENU_READ_PROMPT
	unset USER_CONFIRM_CHOICES_ANSWER
	SUBMENU_READ_PROMPT="$(echo -e " ${ITALIC}${DIM}Select an option (using its number... 1 or 2) :${RESET} ")"

	echo -e "${BOLD}--------------------------------------------------------------         ${RESET}"
	echo -e "  ${DIM}${BOLD}(Review your selections, entries, and choices listed above...) ${RESET}"
	echo -e "   ${BOLD}[1].${RESET}${YELLOW} Make changes.                                 ${RESET}"
	echo -e "   ${BOLD}[2].${RESET}${YELLOW} Confirm choices and continue.                 ${RESET}"
	echo -e "${DIM}--------------------------------------------------------------          ${RESET}"
	read -rp " ${SUBMENU_READ_PROMPT}" USER_CONFIRM_CHOICES_ANSWER
	
	echo "${USER_CONFIRM_CHOICES_ANSWER}"
}

# @function ~ Allow (ask) user to select DNS Provider and enter relevant credentials
function choose_dns_provider() {
	
	local MENU_READ_PROMPT
	local DNS_OPTION

	MENU_READ_PROMPT="$(echo -e " ${ITALIC}${DIM}Select an option (using its number... 1, 2, or 3) :${RESET} ")"

	echo -e "\n\n${DIM}--------------------------------------------------------------${RESET}"
	echo -e "  ${BOLD}${GREEN}Choose DNS Provider 		      ${RESET}"
	echo -e "${DIM}--------------------------------------------------------------${RESET}"
	echo -e "    ${BOLD}[1].${RESET} ${YELLOW}Cloudflare 	  ${RESET}"
	echo -e "    ${BOLD}[2].${RESET} ${YELLOW}GoDaddy 			${RESET}"
	echo -e "    ${BOLD}[3].${RESET} ${YELLOW}Namecheap 		${RESET}"
	echo -e "${DIM}--------------------------------------------------------------${RESET}"
	read -rp " ${MENU_READ_PROMPT}" DNS_OPTION

	case "${DNS_OPTION}" in
		1) DNS_PROVIDER="Cloudflare";;
		2) DNS_PROVIDER="GoDaddy";;
		3) DNS_PROVIDER="Namecheap";;
		*) print_error "Invalid choice. Exiting..."; exit 1;;
	esac

	# Prompt for common entry: Domain Name
	read -rp " * Enter domain name (e.g., example.com): " DOMAIN_NAME
	
	# Prompt for provider-specific credentials (using silent input for secrets)
	if [[ "${DNS_PROVIDER}" == "Cloudflare" ]]; then
		read -rsp " * Enter Cloudflare API Token: " API_TOKEN; echo
		read -rp " * Enter Cloudflare Zone ID: " ZONE_ID
	elif [[ "${DNS_PROVIDER}" == "GoDaddy" ]]; then
		read -rsp " * Enter GoDaddy API Key: " API_KEY; echo
	elif [[ "${DNS_PROVIDER}" == "Namecheap" ]]; then
		read -rsp " * Enter Namecheap API Secret: " API_SECRET; echo
	fi
	
	display_users_current_choices_and_selections
	
	local CONTINUE_OR_CHANGE_ANSWER
	CONTINUE_OR_CHANGE_ANSWER="$(ask_user_to_keep_or_change_current_configurations)"
	
	if [[ "${CONTINUE_OR_CHANGE_ANSWER}" -eq 2 ]]; then
		print_error " [ SORRY THIS FEATURE IS NOT YET IMPLEMENTED... ] "
		exit 1
	fi
}

# @function ~ DNS records setup via DNS provider API
function setup_dns_records() {
	# Get the server's public IP address
	local PUBLIC_IP
	PUBLIC_IP=$(curl -s https://api64.ipify.org)

	print_message "Setting DNS record for ${DOMAIN_NAME} (${DNS_PROVIDER})..."

	case "${DNS_PROVIDER}" in
		"Cloudflare")
			# Cloudflare requires a Zone ID and API Token
			RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
				-H "Authorization: Bearer ${API_TOKEN}" \
				-H "Content-Type: application/json" \
				--data '{"type":"A","name":"'"${DOMAIN_NAME}"'","content":"'"${PUBLIC_IP}"'","ttl":1,"proxied":false}')
			;;
		"GoDaddy")
			RESPONSE=$(curl -s -X PUT "https://api.godaddy.com/v1/domains/${DOMAIN_NAME}/records/A/@?apikey=${API_KEY}" \
				-H "Content-Type: application/json" \
				-d '[{"data": "'"${PUBLIC_IP}"'"}]')
			;;
		"Namecheap")
			# URL-encode the host parameter (@ becomes %40)
			RESPONSE=$(curl -s "https://dynamicdns.park-your-domain.com/update?host=%40&domain=${DOMAIN_NAME}&password=${API_SECRET}&ip=${PUBLIC_IP}")
			;;
	esac

	# Check if the response indicates success
	if [[ "${RESPONSE}" == *"success"* || "${RESPONSE}" == *"OK"* ]]; then
		print_success_message "DNS Record for ${DOMAIN_NAME} added successfully!"
	else
		print_error "Failed to set DNS record. Response: ${RESPONSE}"
	fi
}

# @function ~ Set up SSL and enable SSL auto-renewal
function setup_ssl() {
	# Pre-check to ensure certbot is installed
	if ! command -v certbot >/dev/null 2>&1; then
		print_error "Certbot not found! Please install it first."
		exit 1
	fi

	print_message "Installing and setting up SSL with Let's Encrypt..."
	
	certbot --nginx -d "${DOMAIN_NAME}" --agree-tos --email "admin@${DOMAIN_NAME}" --non-interactive
	print_success_message "SSL certificate installed successfully."

	read -rp "Would you like to enable automatic SSL renewal? (y/N): " SSL_RENEW
	if [[ "${SSL_RENEW,,}" == "y" ]]; then
		echo "0 0 1 * * certbot renew --quiet && systemctl restart nginx" > /etc/cron.d/ssl_renewal
		print_success_message "SSL auto-renewal enabled."
	fi
}

# @function ~ Create cron job to check website availability
function setup_cron_monitoring() {
	read -rp "Enable automatic website monitoring? (y/N): " ENABLE_CRON
	if [[ "${ENABLE_CRON,,}" == "y" ]]; then
		echo "*/10 * * * * curl -Is http://${DOMAIN_NAME} | head -n 1 | grep '200 OK' || echo 'Website DOWN' >> /var/log/site_monitor.log" > /etc/cron.d/site_monitor
		print_success_message "Website monitoring enabled to check every 10 minutes."
	fi
}

# @function ~ Restart Nginx service
function restart_nginx() {
	print_message "Restarting Nginx..."
	systemctl restart nginx && print_success_message "Nginx server restarted."
}

# @function ~ Display fancy, stylized, colorized 'Setup Menu' options to STDOUT
function print_main_menu_options() {
	clear
	echo -e "${GREEN}${DIM}--------------------------------------------------------${RESET}"
	echo -e "${BOLD}${GREEN}${ITALIC}  SETUP OPTIONS ${RESET}"
	echo -e "${GREEN}${DIM}--------------------------------------------------------${RESET}"
	echo -e "${BOLD}  1).${RESET} ${YELLOW}Choose DNS Provider & Set DNS Records ${RESET}"
	echo -e "${BOLD}  2).${RESET} ${YELLOW}Setup SSL & Auto-Renewal ${RESET}"
	echo -e "${BOLD}  3).${RESET} ${YELLOW}Enable Website Monitoring (Cron Job) ${RESET}"
	echo -e "${BOLD}  4).${RESET} ${YELLOW}Restart Web Server ${RESET}"
	echo -e "${BOLD}  5).${RESET} ${RED}Exit ${RESET}"
}

# @function ~ Display setup menu to user and get their choice
function show_main_menu() {
	
	local MAIN_MENU_READ_PROMPT
	MAIN_MENU_READ_PROMPT="\n ${ITALIC}${DIM}${CYAN}Choose an option ${RESET}${ITALIC}${BOLD}[1-5]:${RESET} "
	
	while true; do
		print_main_menu_options
		read -rp "${MAIN_MENU_READ_PROMPT}" OPTION

		case "${OPTION}" in
			1) choose_dns_provider && setup_dns_records ;;
			2) setup_ssl ;;
			3) setup_cron_monitoring ;;
			4) restart_nginx ;;
			5) print_message "Exiting setup..."; break ;;
			*) print_warning "Invalid choice... Please select a valid option." && sleep 3s && clear ;;
		esac
	done
}

# @function ~ Display a cool ASCII/ANSI art-type banner-style program title
function print_fancy_program_title() {
	clear
	echo " ${GREEN}"
	echo "░█▀▀░█▀▀░█▀▄░█░█░█▀▀░█▀▄░░░█▀▀░█▀▀░▀█▀░█░█░█▀█
░▀▀█░█▀▀░█▀▄░▀▄▀░█▀▀░█▀▄░░░▀▀█░█▀▀░░█░░█░█░█▀▀
░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░░░▀▀▀░▀▀▀░░▀░░▀▀▀░▀░░"
	echo " ${RESET}"
	echo " "
}

#---[Main Program Function]-----------------------------------------------------

# @function ~ Main execution function
function program() {
	print_fancy_program_title
	check_root
	install_dependencies
	show_main_menu
}

#-------------------------------------------------------------------------------
# Program Execution Runtime (i.e., execute program)
#-------------------------------------------------------------------------------

program

#===============================================================================
# Script End
#===============================================================================
The transaction has been completed successfully.

