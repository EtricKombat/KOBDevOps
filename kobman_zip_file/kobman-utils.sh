#!/usr/bin/env bash


function __kobman_echo_debug {
	if [[ "$kobman_debug_mode" == 'true' ]]; then
		echo "$1"
	fi
}

function __kobman_secure_curl {
	if [[ "${kobman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location "$1"
	else
		curl --silent --location "$1"
	fi
}

function __kobman_secure_curl_download {
	local curl_params="--progress-bar --location"
	if [[ "${kobman_insecure_ssl}" == 'true' ]]; then
		curl_params="$curl_params --insecure"
	fi

	local cookie_file="${KOBMAN_DIR}/var/cookie"

	if [[ -f "$cookie_file" ]]; then
		local cookie=$(cat "$cookie_file")
		curl_params="$curl_params --cookie $cookie"
	fi

	if [[ ! -z "${kobman_curl_retry}" ]]; then
		curl_params="--retry ${kobman_curl_retry} ${curl_params}"
	fi

	if [[ ! -z "${kobman_curl_retry_max_time}" ]]; then
		curl_params="--retry-max-time ${kobman_curl_retry_max_time} ${curl_params}"
	fi

	if [[ "${kobman_curl_continue}" == 'true' ]]; then
		curl_params="-C - ${curl_params}"
	fi

	if [[ "${kobman_debug_mode}" == 'true' ]]; then
		curl_params="--verbose ${curl_params}"
	fi

	if [[ "$zsh_shell" == 'true' ]]; then
		curl ${=curl_params} "$@"
	else
		curl ${curl_params} "$@"
	fi
}

function __kobman_secure_curl_with_timeouts {
	if [[ "${kobman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location --connect-timeout ${kobman_curl_connect_timeout} --max-time ${kobman_curl_max_time} "$1"
	else
		curl --silent --location --connect-timeout ${kobman_curl_connect_timeout} --max-time ${kobman_curl_max_time} "$1"
	fi
}

function __kobman_page {
	if [[ -n "$PAGER" ]]; then
		"$@" | eval $PAGER
	elif command -v less >& /dev/null; then
		"$@" | less
	else
		"$@"
	fi
}

function __kobman_echo {
	if [[ "$kobman_colour_enable" == 'false' ]]; then
		echo -e "$2"
	else
		echo -e "\033[1;$1$2\033[0m"
	fi
}

function __kobman_echo_red {
	__kobman_echo "31m" "$1"
}

function __kobman_echo_no_colour {
	echo "$1"
}

function __kobman_echo_yellow {
	__kobman_echo "33m" "$1"
}

function __kobman_echo_green {
	__kobman_echo "32m" "$1"
}

function __kobman_echo_cyan {
	__kobman_echo "36m" "$1"
}

function __kobman_echo_confirm {
	if [[ "$kobman_colour_enable" == 'false' ]]; then
		echo -n "$1"
	else
		echo -e -n "\033[1;33m$1\033[0m"
	fi
}

function __kobman_legacy_bash_message {
	__kobman_echo_red "An outdated version of bash was detected on your system!"
	echo ""
	__kobman_echo_red "We recommend upgrading to bash 4.x, you have:"
	echo ""
	__kobman_echo_yellow "  $BASH_VERSION"
	echo ""
	__kobman_echo_yellow "Need to use brute force to replace candidates..."
}
