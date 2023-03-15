# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the GNU General Public License version 3.

$PRESIGNED_URL = ""             # replace with presigned url from email #
$MODEL_SIZE = "7B,13B,30B,65B"  # edit this list with the model sizes you wish to download #
$TARGET_FOLDER = ""             # where all files should end up #
 #
$N_SHARD_DICT = @{
 "7B" = "0"
 "13B" = "1"
 "30B" = "3"
 "65B" = "7"
 }

Write-Host "Downloading tokenizer"
Invoke-WebRequest -Uri $PRESIGNED_URL.Replace("*", "tokenizer.model") -OutFile $TARGET_FOLDER + "\tokenizer.model" #
Invoke-WebRequest -Uri $PRESIGNED_URL.Replace("*", "tokenizer_checklist.chk") -OutFile $TARGET_FOLDER + "\tokenizer_checklist.chk" #

(Set-Location $TARGET_FOLDER); (md5sum -c tokenizer_checklist.chk)

foreach ($i in $MODEL_SIZE -split ",") {
    Write-Host "Downloading $i"
    mkdir -Force $TARGET_FOLDER/$i
    foreach ($s in 0..$i) {
        $s = $s.ToString("00")
        invoke-webrequest -Uri $PRESIGNED_URL.Replace("*", "$i/consolidated.$s.pth") -outfile $TARGET_FOLDER/$i/consolidated.$s.pth
    }
    invoke-webrequest -Uri $PRESIGNED_URL.Replace("*", "$i/params.json") -outfile $TARGET_FOLDER/$i/params.json
    invoke-webrequest -Uri $PRESIGNED_URL.Replace("*", "$i/checklist.chk") -outfile $TARGET_FOLDER/$i/checklist.chk
    Write-Host "Checking checksums"
    md5sum -c $TARGET_FOLDER/$i/checklist.chk
}