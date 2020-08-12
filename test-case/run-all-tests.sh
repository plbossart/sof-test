#!/bin/bash
set -e

TEST_DIR=$(dirname ${BASH_SOURCE[0]})

testlist="
firmware-presence
firmware-load
tplg-binary
pcm_list
sof-logger
ipc-flood
playback-d100l1r1
capture-d100l1r1
playback-d1l100r1
capture_d1l100r1
playback_d1l1r50
capture_d1l1r50
speaker
pause-resume-playback
pause-resume-capture
volume
signal-stop-start-playback
signal-stop-start-capture
xrun-injection-playback
xrun-injection-capture
simultaneous-playback-capture
multiple-pipeline-playback
multiple-pipeline-capture
multiple-pause-resume
kmod-load-unload
kmod-load-unload-after-playback
suspend-resume
suspend-resume-with-playback
suspend-resume-with-capture"

main()
{
	local failures=()
	local passed=()

	local time_delay=3

	while getopts "hT:" OPTION; do
	case "$OPTION" in
		T) time_delay="$OPTARG" ;;
		*) usage; exit 1 ;;
		esac
	done
	if [ -z "$TPLG" ]; then
		printf "Please specify topology path with TPLG env\n"
		exit 1
	fi

	for t in $testlist;
	do
		printf "\033[40;32m ---------- \033[0m\n"
		printf "\033[40;32m ---------- \033[0m\n"
		printf "\033[40;32m starting test_%s \033[0m\n" "$t"
		if "test_$t"; then passed+=( "$t" ); else failures+=( "$t" ); fi
		
		sleep "$time_delay"
	done

	printf "\n\nPASS:"; printf ' %s;' "${passed[@]}"
	if [ "${#failures[@]}" -gt 0 ]; then
	    printf "\nFAIL:"; printf ' %s;' "${failures[@]}"
	fi

	printf "\n\n\033[40;32m test end with %d failed tests\033[0m\n\n" "${#failures[@]}"
	exit "${#failures[@]}"
}

test_firmware-presence()
{
	$TEST_DIR/verify-firmware-presence.sh
}
test_firmware-load()
{
	$TEST_DIR/verify-sof-firmware-load.sh
}
test_tplg-binary()
{
	$TEST_DIR/verify-tplg-binary.sh
}
test_pcm_list()
{
	$TEST_DIR/verify-pcm-list.sh
}
test_sof-logger()
{
	$TEST_DIR/check-sof-logger.sh
}
test_ipc-flood()
{
	$TEST_DIR/check-ipc-flood.sh -l 10
}
test_playback-d100l1r1()
{
	$TEST_DIR/check-playback.sh -d 100 -l 1 -r 1
}
test_capture-d100l1r1()
{
	$TEST_DIR/check-capture.sh -d 100 -l 1 -r 1
}
test_playback-d1l100r1()
{
	$TEST_DIR/check-playback.sh -d 1 -l 100 -r 1
}
test_capture_d1l100r1()
{
	$TEST_DIR/check-capture.sh -d 1 -l 100 -r 1
}
test_playback_d1l1r50()
{
	$TEST_DIR/check-playback.sh -d 1 -l 1 -r 50
}
test_capture_d1l1r50()
{
	$TEST_DIR/check-capture.sh -d 1 -l 1 -r 50
}
test_speaker()
{
	$TEST_DIR/test-speaker.sh -l 50
}
test_pause-resume-playback()
{
	$TEST_DIR/check-pause-resume.sh -c 100 -m playback
}
test_pause-resume-capture()
{
	$TEST_DIR/check-pause-resume.sh -c 100 -m capture
}
test_volume()
{
	$TEST_DIR/volume-basic-test.sh -l 100
}
test_signal-stop-start-playback()
{
	$TEST_DIR/check-signal-stop-start.sh -m playback -c 50
}
test_signal-stop-start-capture()
{
	$TEST_DIR/check-signal-stop-start.sh -m capture -c 50
}
test_xrun-injection-playback()
{
	$TEST_DIR/check-xrun-injection.sh -m playback -c 50
}
test_xrun-injection-capture()
{
	$TEST_DIR/check-xrun-injection.sh -m capture -c 50
}
test_simultaneous-playback-capture()
{
	$TEST_DIR/simultaneous-playback-capture.sh -l 50
}
test_multiple-pipeline-playback()
{
	$TEST_DIR/multiple-pipeline-playback.sh -l 50
}
test_multiple-pipeline-capture()
{
	$TEST_DIR/multiple-pipeline-capture.sh -l 50
}
test_multiple-pause-resume()
{
	$TEST_DIR/multiple-pause-resume.sh -r 25
}
test_kmod-load-unload()
{
	$TEST_DIR/check-kmod-load-unload.sh -l 50
}
test_kmod-load-unload-after-playback()
{
	$TEST_DIR/check-kmod-load-unload-after-playback.sh -l 15
}
test_suspend-resume()
{
	$TEST_DIR/check-suspend-resume.sh -l 50
}
test_suspend-resume-with-playback()
{
	$TEST_DIR/check-suspend-resume-with-audio.sh -l 15 -m playback
}
test_suspend-resume-with-capture()
{
	$TEST_DIR/check-suspend-resume-with-audio.sh -l 15 -m capture
}

usage()
{
	cat <<EOF
Wrapper script to run all test cases. Please use TPLG env to
pass-through topology path to test caess.

usage: run-all-tests.sh [options]
		-h Show script usage
		-T time Delay between cases, default: 3s
EOF
}

main "$@"
