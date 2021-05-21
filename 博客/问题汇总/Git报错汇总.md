## cannot lock ref 'refs/remotes/origin/dev/1.11.0': 'refs/remotes/origin/dev' 



【解决方案】

原因是已经删除远程dev分支

- git fetch -p origin
- git pull

