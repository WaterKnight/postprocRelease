git init

git rm *

git submodule add -f "D:\Warcraft III\Mapping\postproc\.git" "postproc"

git submodule add -f "D:\Warcraft III\Mapping\waterlua\.git" "postproc/waterlua"
git submodule add -f "D:\Warcraft III\Mapping\wc3libs\.git" "postproc/wc3libs"
git submodule add -f "D:\Warcraft III\Mapping\procTools\.git" "postproc/procTools"

git commit -a -m "new version"

git config remote.origin.url https://WaterKnight:gitshit7@github.com/WaterKnight/postprocAndFriends.git

git remote add origin git@github.com:WaterKnight/postprocAndFriends.git

git push -u origin master