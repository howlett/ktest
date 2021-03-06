# xfstests wrapper:

require-lib test-libs.sh

#require-file xfstests

require-kernel-config FAULT_INJECTION,FAULT_INJECTION_DEBUG_FS,FAIL_MAKE_REQUEST
require-kernel-config MD,BLK_DEV_DM,DM_FLAKEY,DM_SNAPSHOT,DM_LOG_WRITES
require-kernel-config BLK_DEV,BLK_DEV_LOOP
require-kernel-config SCSI_DEBUG=m
require-kernel-config USER_NS

# 038,048,312 require > 10G
config-scratch-devs 14G
config-scratch-devs 14G
config-scratch-devs 14G

config-timeout $(stress_timeout)

list_tests()
{
    (cd "$ktest_dir/tests/xfstests/tests"; echo generic/???)
}

run_xfstests()
{
    FSTYP="$1"
    shift

    export TEST_DEV=/dev/sdb
    export TEST_DIR=/mnt/test
    export SCRATCH_DEV=/dev/sdc
    export SCRATCH_MNT=/mnt/scratch
    export LOGWRITES_DEV=/dev/sdd
    export FSTYP

    grep -q fsgqa /etc/passwd || useradd fsgqa

    # required?
    ln -sf /bin/bash /bin/sh

    mkdir -p $TEST_DIR $SCRATCH_MNT
    mkfs.$FSTYP -q $TEST_DEV
    mount $TEST_DEV $TEST_DIR

    cd "$ktest_dir/tests/xfstests"
    run_quiet "building xfstests" make

    rm -f results/generic/*
    ./check "$@"
}
