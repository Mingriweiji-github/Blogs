<template>
  <div class="huadong">
    <div class="bt">
      <nav>
        <span @click="qh(index)"
              v-for="(item,index) in list"
              :class="{active:show==index+1}"
              :key="index">
          {{item}}
        </span>
      </nav>
 
    </div>
    <div class="nr"
         v-if="index==0">
      <p v-for="(item,index) in nr"
         :key="index">{{item}}</p>
    </div>
    <div class="nr"
         v-if="index==1">
      <p v-for="(item,index) in nrs"
         :key="index">{{item}}</p>
    </div>
    <div class="nr"
         v-if="index==2">
      <p v-for="(item,index) in nrs"
         :key="index">{{item}}</p>
    </div>
    <div class="nr"
         v-if="index==3">
      <p v-for="(item,index) in nrs"
         :key="index">{{item}}</p>
    </div>
    <div class="nr"
         v-if="index==4">
      <p v-for="(item,index) in nrs"
         :key="index">{{item}}</p>
    </div>
    <div class="nr"
         v-if="index==5">
      <p v-for="(item,index) in nrs"
         :key="index">{{item}}</p>
    </div>
    <div class="nr"
         v-if="index==6">
      <p v-for="(item,index) in nrs"
         :key="index">{{item}}</p>
    </div>
    <div class="nr"
         v-if="index==7">
      <p v-for="(item,index) in nrs"
         :key="index">{{item}}</p>
    </div>
  </div>
 
</template>
<script>
export default {
  data () {
    return {
      index: 0,
      show: 1,
      list: ["热门", "推荐", "儿科", "内科", "妇科", "外科", "口腔科", "男科"],
      nr: [1, 2, 3, 4, 5, 6, 7, 8],
      nrs: [8, 7, 6, 5, 4, 3, 2, 1]
    }
  },
  methods: {
    qh: function (index) {
      this.index = index;
      console.log(this.index);
      if (this.index == index) {
        this.show = index + 1;
      }
    }
  },
}
</script>
<style lang="scss">
@function px1rem($px) {
  $rem: 75px;
  @return ($px / $rem) + rem;
}
.huadong {
  width: 100%;
}
.bt {
  width: 100%;
  height: 50px;
  background-color: red;
}
//要滑动必要css
nav {
  padding: 0 10px;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-align: middle;
  -ms-flex-align: middle;
  align-items: middle;
  overflow: auto;
}
span {
  height: 50px;
  line-height: 50px;
  display: inline-block;
  width: 45px;
  font-weight: bolder;
  text-align: center;
  margin-left: 10px;
  -ms-flex-negative: 0; //先把导航栏样式写好,然后加上下面这两句,导航栏可以实现滑动了
  flex-shrink: 0;
}
.active {
  color: white;
}
</style>