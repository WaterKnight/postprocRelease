git init

git rm *

REM git clone "D:\Warcraft III\Mapping\waterlua\.git" "waterlua"
REM git clone "D:\Warcraft III\Mapping\wc3libs\.git" "wc3libs"

git submodule add -f "D:\Warcraft III\Mapping\postproc\.git" "postproc"

git submodule add -f "D:\Warcraft III\Mapping\waterlua\.git" "postproc/waterlua"
git submodule add -f "D:\Warcraft III\Mapping\wc3libs\.git" "postproc/wc3libs"

REM mkdir procTools

git submodule add -f "D:\Warcraft III\Mapping\procTools\embedBuildNumber\.git" "postproc/procTools/embedBuildNumber"
git submodule add -f "D:\Warcraft III\Mapping\procTools\objModToSlk\.git" "postproc/procTools/objModToSlk"
git submodule add -f "D:\Warcraft III\Mapping\procTools\pathFiller\.git" "postproc/procTools/pathFiller"
git submodule add -f "D:\Warcraft III\Mapping\procTools\vjassImport\.git" "postproc/procTools/vjassImport"

REM git clone "D:\Warcraft III\Mapping\procTools\embedBuildNumber\.git" "procTools\embedBuildNumber"
REM git clone "D:\Warcraft III\Mapping\procTools\objModToSlk\.git" "procTools\objModToSlk"
REM git clone "D:\Warcraft III\Mapping\procTools\pathFiller\.git" "procTools\pathFiller"
REM git clone "D:\Warcraft III\Mapping\procTools\vjassImport\.git" "procTools\vjassImport"

REM git clone "D:\Warcraft III\Mapping\postproc\.git" "postproc"

REM git add waterlua\\*
REM git add wc3libs\\*
REM git add procTools\\*
REM git add postproc\\*

REM git add procTools\\embedBuildNumber\\*
REM git add procTools\\objModToSlk\\*
REM git add procTools\\pathFiller\\*
REM git add procTools\\vjassImport\\*

git commit -a -m "new version"

git config remote.origin.url https://WaterKnight:gitshit7@github.com/WaterKnight/postprocAndFriends.git

git remote add origin git@github.com:WaterKnight/postprocAndFriends.git

git push -u origin master