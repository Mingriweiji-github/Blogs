[为什么要Leetcode编程训练](https://coolshell.cn/articles/12052.html)

![图⽚片来源:http://www.bigocheatsheet.com/](http://q2yey8eca.bkt.clouddn.com/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E7%A9%BA%E9%97%B4%E5%A4%8D%E6%9D%82%E5%BA%A6.png)
# 为什么学算法？

#### 为什么要学习算法？

- 算法是内功，决定你武功的高度
- 算法能让你更好更快理解一门语言系统的设计理念
- 算法能让你触类旁通



# 数据结构和算法基础篇

## 数据结构

- [动画| 什么是二分搜索树？](https://mp.weixin.qq.com/s/0nubI8XPcUJYAaEk-Eomrg)
- [动画| 二叉树有几种存储方式？](https://mp.weixin.qq.com/s/h_mO28pmE_uNbHA5GVmWPA)
- [动画| 二叉树在实际生活中的应用？](https://mp.weixin.qq.com/s/tFJqwKa-adXW0kXGxldisg)

- [红黑树](https://mp.weixin.qq.com/s/XqxOp5jXqDg6fez6GphLCA)

## 算法思想
- [什么是递归？](https://mp.weixin.qq.com/s/DFLD41tFVtlXVYgg2QJcsQ)
- [什么是分支？](https://mp.weixin.qq.com/s/G7hlvXeW_qNDPOwnIFteug)
- [Hash算法原理及应用](https://mp.weixin.qq.com/s/Q0w59YQmZN7tWxSXPR1vrA)
- [动画 | 什么是快速排序？](https://mp.weixin.qq.com/s/Rh0O3ifxOtmHocr4NNNSYw)

- [动画：面试官问我插入排序和冒泡排序哪个更牛逼？](https://mp.weixin.qq.com/s/WOpU112IcvRed078mQ8ovA)

- [动画: 快速排序 | 如何求第 K 大元素？](https://mp.weixin.qq.com/s/-9mD9LC4OrN5dl5DQSHyNA)

- [动画| 什么是堆排序？](https://mp.weixin.qq.com/s/nXo4A-_NX_JKmTAbbTYVRg)

- [动画| 什么是希尔排序](https://mp.weixin.qq.com/s/u397yZKJzuyTuzQDCcE7mw)


## 算法题目推荐

- [初级算法](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy)
- [中级算法](https://leetcode-cn.com/explore/interview/card/top-interview-questions-medium/)
- [高级算法](https://leetcode-cn.com/explore/interview/card/top-interview-questions-hard/)




## 1、栈和队列

#### [20. 有效的括号](https://leetcode-cn.com/problems/valid-parentheses/submissions/)

```Swift

func isValid(_ s: String) -> Bool {

var stack: [String] = []

let dic: [String: String] = [")": "(", "}": "{", "]": "["]

for c in s {

let key = String(c)

if !dic.keys.contains(key) {

stack.append(key)

} else if stack.count == 0 || dic[key] != stack.removeLast() {

return false

}

}

return stack.count == 0

}

```

#### 232. [用栈实现队列](https://leetcode-cn.com/problems/implement-queue-using-stacks/solution/)

#### 225. [用队列实现栈](https://leetcode-cn.com/problems/implement-stack-using-queues/solution/)

## 2、[链表](https://leetcode-cn.com/tag/linked-list/)

```Java
public class ListNode {

int val;

ListNode next;

ListNode(int x) { val = x; }

}

```

##### 

#### 1： [删除链表中的节点](https://leetcode-cn.com/problems/delete-node-in-a-linked-list/)



```Java

class Solution {

public void deleteNode(ListNode node) {

node.val = node.next.val;

node.next = node.next.next;

}

}

```

#### 2：[翻转链表](https://leetcode-cn.com/problems/reverse-linked-list/)

> 题目描述：反转一个单链表。

Solution1: 递归法

![链表翻转](http://q2yey8eca.bkt.clouddn.com/%E9%80%92%E5%BD%92%E7%BF%BB%E8%BD%AC.png)

```Java

public ListNode reverseList(ListNode head) {

if(head == null) return head;

if(head.next == null) return head;

ListNode newHead = reverseList(head.next);

head.next.next = head;

head.next = null;

return newHead;

}

```

Solotion2: 非递归

> 错误示例：第三行

```Java

public ListNode reverseList(ListNode head) {

if(head == null) return head;

if(head.next == null) return head;

ListNode newHead = ListNode();

while (head != null) {

ListNode temp = head.next;

head.next = newHead;

newHead = head;

head = temp;

}

return newHead;

}

```

> 正确示例

```Java

public ListNode reverseList(ListNode head) {

if(head == null) return head;

if(head.next == null) return head;

ListNode newHead = null;

while (head != null) {

ListNode temp = head.next;

head.next = newHead;

newHead = head;

head = temp;

}

return newHead;

}

```

#### 3：[反转链表 II](https://leetcode-cn.com/problems/reverse-linked-list-ii/)

> 题目描述：反转从位置 m 到 n 的链表。请使用一趟扫描完成反转。

>说明:

1 ≤ m ≤ n ≤ 链表长度。

#### 4：[环形链表](https://leetcode-cn.com/problems/linked-list-cycle/)

> 第一步：找到快慢指针相遇的节点，如果找不到，证明没有环，返回null

第二步：head节出发与slow节点出发，相遇的节点为环的入口节点

```Java

public boolean hasCycle(ListNode head) {

if (head == null || head.next == null) { return false; }

ListNode fast = head.next;

ListNode slow = head;

while (fast.next != null && fast.next.next != null) {

slow = slow.next;

fast = fast.next.next;

if (fast == slow) {

return true;

}

}

return fast == slow;

}

```

#### 5：环形链表II-寻找环的入口节点

> 问题描述：给定一个链表，返回链表开始入环的第一个节点。 如果链表无环，则返回 null。

> 为了表示给定链表中的环，我们使用整数 pos 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 pos 是 -1，则在该链表中没有环。

> 说明：不允许修改给定的链表。

[官方解读Gif](https://leetcode-cn.com/problems/linked-list-cycle-ii/solution/huan-xing-lian-biao-ii-by-leetcode/)

![环形链表入口](http://q2yey8eca.bkt.clouddn.com/%E7%8E%AF%E5%BD%A2%E9%93%BE%E8%A1%A8II.gif)

#### 6：[703. 数据流中的第K大元素](https://leetcode-cn.com/problems/kth-largest-element-in-a-stream/solution/)

```Java

public class KthLargest {

private PriorityQueue<Integer> queue;

private int limit;

public KthLargest(int k, int[] nums) {

limit = k;

queue = new PriorityQueue<>(k);

for (int num : nums) {

add(num);

}

}

public int add(int val) {

if (queue.size() < limit) {

queue.add(val);

} else if (val > queue.peek()) {

queue.poll();

queue.add(val);

}

return queue.peek();

}

}

```

## 3、优先队列

1. Heap (Binary, Binomial, Fibonacci)

2. Binary Search Tree

![Mini Heap](https://imgkr.cn-bj.ufileos.com/c3688989-5aaa-49cd-ba04-eb46bf8d2cbf.png)

![Max Heap](https://imgkr.cn-bj.ufileos.com/4e377821-42a4-4517-8179-234b3d68e0f9.png)

Heap Wiki

• https://en.wikipedia.org/wiki/Heap_(data_structure)

#### 239、[滑动窗口最大值](https://leetcode-cn.com/problems/sliding-window-maximum/)

## 4、哈希表 与双指针法

#### [1. 两数之和](https://leetcode-cn.com/problems/two-sum/)

1.1[暴力循环](https://leetcode-cn.com/problems/two-sum/solution/liang-shu-zhi-he-by-leetcode-2/)

[1.2一次哈希思路](https://leetcode-cn.com/problems/two-sum/solution/jie-suan-fa-1-liang-shu-zhi-he-by-guanpengchn/)
标签：哈希映射

- 这道题本身如果通过暴力遍历的话也是很容易解决的，时间复杂度在 O(n2)
- 由于哈希查找的时间复杂度为 O(1)，所以可以利用哈希容器 map 降低时间复杂度
- 遍历数组 nums，i 为当前下标，每个值都判断map中是否存在 target-nums[i] 的 key 值
- 如果存在则找到了两个值，如果不存在则将当前的 (nums[i],i) 存入 map 中，继续遍历直到找到为止
- 如果最终都没有结果则抛出异常
- 时间复杂度：O(n)



#### 15. [三数之和](https://leetcode-cn.com/problems/3sum/)  (硅谷面试)

给定一个包含 n 个整数的数组 nums，判断 nums 中是否存在三个元素 a，b，c ，使得 a + b + c = 0 ？找出所有满足条件且不重复的三元组。

> 注意：答案中不可以包含重复的三元组。

解题思路：

- 1、可以三重loops循环时间复杂度是O(*n3*)
- 2、可以两层循环得到a+b,然后在Set集合中查找符合-(a+b)的值是否存在，时间复杂度是O(*n*2)
- 3、先排序 后查找：时间复杂度为O(*n*2)，先排序后得到元素a, 元素b从数组下标1开始，元素c从数组下标array.length开始，检查（a + b + c）的值：
  - 如果（a + b + c）> 0, c--
  - 如果 （a + b + c）< 0, b++
  - 如果（a + b + c） == 0， 得到结果
  - 整个过程时间复杂度是O(N * N)

[解题思路3](https://leetcode-cn.com/problems/3sum/solution/hua-jie-suan-fa-15-san-shu-zhi-he-by-guanpengchn/) 





```Java

    public static List<List<Integer>> threeSum(int[] nums) {
        List<List<Integer>> ans = new ArrayList();
        int len = nums.length;
        if(nums == null || len < 3) return ans;
        Arrays.sort(nums); // 排序
        for (int i = 0; i < len ; i++) {
            if(nums[i] > 0) break; // 如果当前数字大于0，则三数之和一定大于0，所以结束循环
            if(i > 0 && nums[i] == nums[i-1]) continue; // 去重
            int L = i+1;
            int R = len-1;
            while(L < R){
                int sum = nums[i] + nums[L] + nums[R];
                if(sum == 0){
                    ans.add(Arrays.asList(nums[i],nums[L],nums[R]));
                    while (L<R && nums[L] == nums[L+1]) L++; // 去重
                    while (L<R && nums[R] == nums[R-1]) R--; // 去重
                    L++;
                    R--;
                }
                else if (sum < 0) L++;
                else if (sum > 0) R--;
            }
        }        
        return ans;
    }

作者：guanpengchn
链接：https://leetcode-cn.com/problems/3sum/solution/hua-jie-suan-fa-15-san-shu-zhi-he-by-guanpengchn/

```

#### 求最小公倍数LCM

GCD：最大公约数(Greatest Common Divisor)。指两个或多个整数共有约数中最大的一个。

LCM：最小公倍数(Least Common Multiple)。两个或多个整数公有的倍数叫做它们的公倍数，其中除0以外最小的一个公倍数就叫做这几个整数的最小公倍数。

最小公倍数与最大公约数的关系：** 

```
LCM(A,B)×GCD(A,B)=A×B
```

其中LCM是最小公倍数，GCD是最大公约数。

```Swift
//MARK:求最小公倍数 
func lcm(_ a:Int,_ b:Int) -> Int {
  //求最大公约数    
  let num:Int = gcd(a,b)
  return a * b / num
}
```

所以求最小公倍数的问题可以转化为求最大公约数。

####  [18. 四数之和](https://leetcode-cn.com/problems/4sum/)

#### 拓展：[K数之和](https://leetcode-cn.com/problems/4sum/solution/kshu-zhi-he-de-tong-yong-mo-ban-by-mrxiong/)

#### [242、有效的字母异位词](https://leetcode-cn.com/problems/valid-anagram/)

## 5、二叉树

### 10道常见题目

- [二叉树的前序遍历：（递归+迭代）](https://leetcode-cn.com/problems/binary-tree-preorder-traversal/)
- [二叉树的中序遍历：（递归+迭代）](https://leetcode-cn.com/problems/binary-tree-inorder-traversal/)
- [二叉树的后序遍历：（递归+迭代）](https://leetcode-cn.com/problems/binary-tree-postorder-traversal/)
- [二叉树的层次遍历：（迭代）](https://leetcode-cn.com/problems/binary-tree-level-order-traversal/)
- [二叉树的层次遍历II](https://leetcode-cn.com/problems/binary-tree-level-order-traversal-ii/)

- [二叉树的最大深度：（递归+迭代）](https://leetcode-cn.com/problems/maximum-depth-of-binary-tree/)

- [二叉树最大宽度](https://leetcode-cn.com/problems/maximum-width-of-binary-tree/)
- [对称二叉树](https://leetcode-cn.com/problems/symmetric-tree/)

- [翻转一颗二叉树](https://leetcode-cn.com/problems/invert-binary-tree)



- [从中序与后序遍历序列构造二叉树](https://leetcode-cn.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/)
- [从前序与中序遍历序列构造二叉树](https://leetcode-cn.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/)
- [从前序和后序遍历构造二叉树](https://leetcode-cn.com/problems/construct-binary-tree-from-preorder-and-postorder-traversal/)
- [二叉树展开为链表:  （迭代+递归 )](https://leetcode-cn.com/problems/flatten-binary-tree-to-linked-list/)
- 思考：已知前序、中序遍历结果求后序遍历
- 思考：已知中序、后序遍历结果求前序遍历

- [Objective-C版本](https://juejin.im/post/5c46b19ee51d45653e3c9ae3#heading-13)



## DFS与BFS概念

- DFS 深度优先搜索：以深度为优先级，从根节点开始一直到达叶子结点，再返回根到达另一个分支。可以细分为先序遍历，中序遍历和后序遍历。

- BFS 广度优先搜索：按照高度顺序一层一层地访问，高层的结点会比低层的结点先被访问到。相当于层次遍历。

### 递归法

#### 1、前序遍历

前序遍历递归法：左子树-根节点-右子树

```Swift
func preorderTraversal(_ root: TreeNode?) -> [Int] {
    guard let root = root else { return[]}

    var res: [Int] = []
    res.append(root.val)
    res += preorderTraversal(root.left)
    res += preorderTraversal(root.right)

    return res

}
```



#### 2、中序遍历

中序遍历递归法：左子树-根节点-右子树

```Swift
func inorderTraversal(_ root: TreeNode?) -> [Int] {
        guard let root = root else  { 
            return []
        }
        var res: [Int] = []
        res += inorderTraversal(root.left)
        res.append(root.val)
        res += inorderTraversal(root.right)
        
        return res
}

```



#### 3、后序遍历

后序遍历递归法：左子树-右子树-根节点

```Swift
func postorderTraversal(_ root: TreeNode?) -> [Int] {
    guard let root = root else { return [] }
    var result: [Int] = []
    if let left = root.left {
        result += postorderTraversal(left)
    }
    if let right = root.right {
        result += postorderTraversal(right)
    }
    result.append(root.val)
    return result
}
```

#### 4.1、[二叉树的层次遍历](https://leetcode-cn.com/problems/binary-tree-level-order-traversal/)



![该图是借用的网上的，侵权删](https://img-blog.csdn.net/20180226001828381)

图片来自网络，侵权删

实现思路：使用队列
1.将根节点入队
2.循环执行以下操作，直到队列为空

>  - 将队头节点A出队，进行访问
>  - 将A的左子节点入队
>  - 将A的右子节点入队

```Swift
func levelOrder(_ root: TreeNode?) -> [[Int]] {
      guard let root = root else { return []}
      var result: [[Int]] = []
      var queue: [TreeNode] = []
      queue.append(root)
      while !queue.isEmpty {
          //创建存储当前level的数组
          var level: [Int] = []
          for _ in 0..<queue.count {
              //remove队列头结点，并且把该头结点的left和right加入到队列中，循环到队列为空
              let node = queue.removeFirst()
              level.append(node.val)
              if let left = node.left { queue.append(left) }
              if let right = node.right { queue.append(right)}
          }
          result.append(level)

      }

      return result
}
```

#### 4.2、[二叉树的层次遍历 II](https://leetcode-cn.com/problems/binary-tree-level-order-traversal-ii/)

从下到上依次返回每一层的结果，解决方案依然是使用队列的先进先出，node入队列的通知，node的左子树、右子树依次入队列，然后用一个temp数组来保存每一层的数值，插入到结果results数组下标位置为0的位置。

代码如下：

```Swift
func levelOrderBottom(_ root: TreeNode?) -> [[Int]] {
    guard let root = root else { return [] }
    var results: [[Int]] = []
    var queue: [TreeNode] = [root]
    while !queue.isEmpty {
        var levelItems: [Int] = []
        for _ in 0..<queue.count {
            let node = queue.removeFirst()
            levelItems.append(node.val)
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        results.insert(levelItems, at: 0)
    }
    return results
}
```



**自底向上返回层次遍历的值与普通的层次遍历的唯一区别在于每一层的结果levelItems是插入到数组下标为0的位置上，利用swift中数组插入方法insert(levelItems,at: 0)即可。**

#### 4.2、迭代法解决前中后序

**递归和非递归的区别，无非是一个人为保存现场，一个代码底层自动保存现场。**

#### 前序遍历迭代法

- 利用栈实现
  1.将root入栈
  2.循环执行以下操作，直到栈为空
  - 弹出栈顶节点top，进行访问
  - 将top.right入栈
  - 将top.left入栈



#### 中序遍历迭代法

利用栈实现
1.设置node=root 
2.循环执行以下操作
✓如果node!=null 
✓将node入栈
✓设置node=node.left 
✓如果node==null 
✓如果栈为空，结束遍历
✓如果栈不为空，弹出栈顶元素并赋值给node

​	 ➢对node进行访问
​	➢设置node=node.right

#### 后序遍历迭代法

◼利用栈实现
1.将root入栈
2.循环执行以下操作，直到栈为空

- 如果栈顶节点是叶子节点或者上一次访问的节点是栈顶节点的子节点

  ✓弹出栈顶节点，进行访问

  否则
  ✓将栈顶节点的right、left按顺序入栈

---

#### [5、 二叉树的最大深度](https://leetcode-cn.com/problems/maximum-depth-of-binary-tree/)

首先要明白什么是最大深度：二叉树最大深度是指根节点到最远的叶子节点最长路径上的节点数目

解法一：要求二叉树的最大深度按照递归思想也就是求max(leftHeight, rightHeight) + 1

```Swift
//1、递归法：max(leftHeight, rightHeight) + 1
func maxDepth(_ root: TreeNode?) -> Int {
    if let root = root {
        var leftHeight = 0, rightHeight = 0
        if let left = root.left { leftHeight = maxDepth(left) }
        if let right = root.right { rightHeight = maxDepth(right) }
        return max(leftHeight, rightHeight) + 1
    }
    return 0
}
```

解放二：使用队列，分层遍历DFS，记录层数即可

```Swift
  //2、利用队列-和分层遍历类似
  //只不过分层遍历是头结点出队列时，将头队列的值保存起来，这里求最大深度是depth += 1
  func maxDepth(_ root: TreeNode?) -> Int {
  guard let root = root else { return 0 }
  var depth = 0
  var queue: [TreeNode] = [root]
  while !queue.isEmpty {
      depth += 1
      let size = queue.count
      for _ in 0..<size {
          let node = queue.removeFirst()
          if let left = node.left { queue.append(left) }
          if let right = node.right { queue.append(right) }
      }
  }
  return depth
```





#### [6、 二叉树最大宽度](https://leetcode-cn.com/problems/maximum-width-of-binary-tree/)




#### [7、 验证二叉搜索树](https://leetcode-cn.com/problems/validate-binary-search-tree/)

1、递归法

递归法解题的关键在于：
- 1、临界条件:root==null 
- 2、递归左子树，找到最大值max和根节点root.val进行比较，如果左子树的max大于等于根节点的值，返回false
- 3、递归右子树，找到右子树的最小值min和根节点root.val比较，如果右子树的min小于等于根节点，返回false


```Java
	public boolean helper(TreeNode root, Integer min, Integer max) {
        if (root == null) return true;

        if (min != null && min > root.val) return false;
        if (max != null && max < root.val) return true;

        return helper(root.left,min,root.val) && helper(root.right,root.val,max);
        
    }
    public boolean isValidBST(TreeNode root) {
        return helper(root,null,null);
    }

```

上面的help()方法不能通过测试用例[1,1]这种重复元素的数组，判断条件错误，修改如下：

Java版本

```Java
public boolean helper(TreeNode root, Integer min, Integer max) {
        if (root == null) return true;

        if (min != null && min >= root.val) return false;
        if (max != null && max <= root.val) return true;

        return helper(root.left,root.val,max) && helper(root.right,min,root.val);
        
}
```

Swift版本:注意可选项解包，和判断条件是left.max >= root.val, right.min <= root.val

```Swift
		func isValidBST(_ root: TreeNode?) -> Bool {
        guard let root = root else { return true }
        return helper(root,nil,nil)
    }

    func helper(_ root: TreeNode?, _ min: Int?, _ max: Int?) -> Bool {
        guard let root = root else { return true }

      //左节点需要小于根节点值
        if let min = min,
        min <= root.val {
            return false
        }
      //右节点需要大于根节点
        if let max = max,
        max >= root.val {
            return false
        }
        return helper(root.left, root.val,max) && helper(root.right, min, root.val)
    }
```

#### 8、对称二叉树

解题思路：给定一个二叉树，看它是否镜像对称关键是1、左右子树的值相等 2、左子树的left和右子树的right是镜像对称，利用递归思想容易解决。

24ms代码实现如下:

```Swift
  func isSymmetric(_ root: TreeNode?) -> Bool {
      return isMirror(root,root)
  }
  func isMirror(_ p: TreeNode?, _ q: TreeNode?) -> Bool{
      //注意临界条件判断，先判断p、q均为空的情况
      if p == nil && q == nil {
          return true
      }
      if p == nil || q == nil {
          return false
      }         
      return (p!.val == q!.val) && isMirror(p!.left, q!.right) && isMirror(p!.right, q!.left)
  }
```

20ms代码实现如下：

```Swift
 func isSymmetric(_ root: TreeNode?) -> Bool {
      guard let root = root else { return true }
      return isMirror(root.left, root.right)
  }
  func isMirror(_ p: TreeNode?, _ q: TreeNode?) -> Bool {
      if p == nil, q == nil {
          return true
      }
      if let p = p, let q = q, p.val == q.val {
          return isMirror(p.left, q.right) && isMirror(p.right, q.left)
      }
      return false
  }
```



#### [9、翻转一颗二叉树](https://leetcode-cn.com/problems/invert-binary-tree)

迭代就要遍历二叉树，利用队列交换每个结点的左右子树。

8ms迭代法：

```Swift
func invertTree(_ root: TreeNode?) -> TreeNode? {
        //迭代法翻转二叉树,交换每一个结点的左右子树，我们用队列储存没有交换过的左右子树的结点，拿到current结点后，交换左右结点，然后再将该节点的左右结点加入到队列中。直到队列为空截止。
        guard let root = root else { return nil }
        var queue: [TreeNode] = [root]
        while !queue.isEmpty {
            var node = queue.removeFirst()
            let temp = node.left
            node.left = node.right
            node.right = temp
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        return root
    }
```

16ms递归法：

```Swift
func invertTree(_ root: TreeNode?) -> TreeNode? {
        guard let root = root else { return nil }
        let temp = root.left
        root.left = root.right
        root.right = temp
        
        invertTree(root.left)
        invertTree(root.right)

        return root
    }
```

8ms递归法：同上面的区别是没有解包，解包耗时8ms?

```Swift
func invertTree(_ root: TreeNode?) -> TreeNode? {
    if root == nil { return nil }
    let temp = root?.left
    root?.left = root?.right
    root?.right = temp

    invertTree(root?.left)
    invertTree(root?.right)

    return root
}
```

## 6、二叉树搜索树

### 10道常见题目

- #### [ 验证二叉搜索树](https://leetcode-cn.com/problems/validate-binary-search-tree/)

- #### [二叉搜索树中的插入操作](https://leetcode-cn.com/problems/insert-into-a-binary-search-tree/)

- #### [二叉搜索树中的搜索](https://leetcode-cn.com/problems/search-in-a-binary-search-tree/)

- #### [删除二叉搜索树中的节点](https://leetcode-cn.com/problems/delete-node-in-a-bst/)

- #### [二叉搜索树的最小绝对差](https://leetcode-cn.com/problems/minimum-absolute-difference-in-bst/)

- #### [二叉搜索树结点最小距离](https://leetcode-cn.com/problems/minimum-distance-between-bst-nodes/)

- #### [将有序数组转换为二叉搜索树](https://leetcode-cn.com/problems/convert-sorted-array-to-binary-search-tree/) *

- #### [二叉搜索树的范围和](https://leetcode-cn.com/problems/range-sum-of-bst/) *

- #### [二叉搜索树的最近公共祖先](https://leetcode-cn.com/problems/lowest-common-ancestor-of-a-binary-search-tree/) *

- #### [二叉搜索树中第K小的元素](https://leetcode-cn.com/problems/kth-smallest-element-in-a-bst/) **

- #### [二叉搜索树迭代器](https://leetcode-cn.com/problems/binary-search-tree-iterator/) **

- #### [恢复二叉搜索树](https://leetcode-cn.com/problems/recover-binary-search-tree/)

- #### [平衡二叉树](https://leetcode-cn.com/problems/balanced-binary-tree/)

  