[为什么要Leetcode编程训练](https://coolshell.cn/articles/12052.html)

![图⽚片来源:http://www.bigocheatsheet.com/](http://q2yey8eca.bkt.clouddn.com/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E7%A9%BA%E9%97%B4%E5%A4%8D%E6%9D%82%E5%BA%A6.png)



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



####  [18. 四数之和](https://leetcode-cn.com/problems/4sum/)

#### 拓展：[K数之和](https://leetcode-cn.com/problems/4sum/solution/kshu-zhi-he-de-tong-yong-mo-ban-by-mrxiong/)

#### [242、有效的字母异位词](https://leetcode-cn.com/problems/valid-anagram/)

## 5、二叉树二叉搜索树BST

#### [98. 验证二叉搜索树](https://leetcode-cn.com/problems/validate-binary-search-tree/)

1、递归法

- 限定每个节点值的范围来验证二叉搜索树。
- 遍历节点root时，给出root值的范围(minv,maxv), minv < root.val < maxv
- 当root.val超出 范围(minv,maxv) 时，就不算二叉搜索树了。
- 递归左子树时，左子树的最大值不能超过root的值。
- 递归左子树时，右子树的最小值不能小于root的值。

作者：jason-2
链接：https://leetcode-cn.com/problems/validate-binary-search-tree/solution/di-gui-fa-by-jason-2/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

```python
    typedef long long ll;
    bool isValidBST(TreeNode* root) {
        return dfs(root,LLONG_MIN,LLONG_MAX);
    }
    
    bool dfs(TreeNode* rt,ll minv,ll maxv){
        if(!rt) return true;
        if(rt->val < maxv && rt->val > minv 
           && dfs(rt->left,minv,rt->val) 
           && dfs(rt->right,rt->val,maxv)) return true;
        return false;
    }

```

[官方解决方案](https://leetcode-cn.com/problems/validate-binary-search-tree/solution/yan-zheng-er-cha-sou-suo-shu-by-leetcode/)

