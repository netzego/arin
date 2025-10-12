An opinionated archlinux installer

<!--
### Dependencies
- make
- whois (mkpasswd)
-->

### Usage
```sh
git clone --depth=1 https://codeberg.org/nzeo/arin.git && cd arin
bash -x ./arin.sh $VOLUME |& tee -p $LOGFILE
```

```console
# mount -o remount,size=4G /run/archiso/cowspace
# git clone --depth=1 https://github.com/netzego/arin.git && cd arin
# bash -x ./arin.sh $VOLUME |& tee -p $LOGFILE
```

### Files
- arin.authorized_keys
- arin.config
- arin.keyfile
- arin.packages
- arin.roothash
- arin.skeleton/

<!-- ### Rationale -->
<!-- ### Assumptions -->
<!-- ### Warranty -->
