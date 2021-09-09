# Git 常用



[7\. 用rebase合并【教程1 操作分支】\| 猴子都能懂的GIT入门 \| 贝格乐（Backlog）](https://backlog.com/git-tutorial/cn/stepup/stepup2_8.html)



Git 关联本地分支和远程分支：git branch --set-upstream-to=origin/dev/1.18.0 dev/1.18.0

> git branch --set-upstream-to=origin/dev/1.18.0 dev/1.18.0



[Git修改本地或远程分支名称](https://juejin.cn/post/6844903880115896327)

1. 旧分支：oldBranch
2. 新分支：newBranch

> 步骤：

1. 先将本地分支重命名

   ```
   git branch -m oldBranch newBranch
   
   ```

2. 删除远程分支（远端无此分支则跳过该步骤）

   ```
   git push --delete origin oldBranch
   
   ```

3. 将重命名后的分支推到远端

   ```
   git push origin newBranch
   
   ```

4. 把修改后的本地分支与远程分支关联

   ```
   git branch --set-upstream-to origin/newBranch
   ```




[git cherry\-pick 教程 \- 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2020/04/git-cherry-pick.html)



