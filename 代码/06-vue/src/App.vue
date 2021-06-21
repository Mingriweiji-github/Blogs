<template>
  <div id="app">
    <div class="box">
        <p>前端小课，每日一课</p>
        <p>前端小课</p>
        <p>postion布局: relative 和 absolute</p>
    </div>
  </div>
</template>

<script>


export default {
  name: 'App',
  components: {
    
  }
}
</script>

<style>
/** postion布局:相对布局 relative */
/*left优先级高于right*/
/*top优先级高于bottom*/
/* * {
  margin: 0;
  padding: 0;
}
.box {
  margin: 10px;
  height: 300px;
  background: #eeeeee;
}
p {
  color: white;
  font-size: 18px;
  line-height: 40px;
}
p:nth-child(1) {
  background-color: red;
} */

/* p:nth-child(2) {
  background-color: blue;
  position: relative;
  left: 20px;
  top: 20px;
  right: 50px;
  bottom: 50px;
}
p:nth-child(3) {
  background-color: black;
} */

/* postion布局：绝对布局absolute */
/* 1 top、bottom、left、right 可以同时使用
如果都设置为 0，此元素所有的父元素没有设置 position 属性时，它会填充满可视区域。 */
/* 2、对某个元素使用 position 属性（relative）来限制子元素的活动范围。 */
/* * {
  margin: 0;
  padding: 0;
}

body {
  height: 1000px;
  background: grey;
}
.box {
  margin: 10px;
  height: 400px;
  background-color: #eeeeee;
  position: relative;
}
p {
  color: wheat;
  font-size: 18px;
  line-height: 40px;
}

p:nth-child(1) {
  background: red;
}
p:nth-child(2) {
  background: green;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
}
p:nth-child(3) {
  background: blue;
} */

/* postion布局：fixed和sticky */
* {
  margin: 0;
  padding: 0;
}

body {
  height: 800px;
}

.box {
  /* margin: 10px; */
  height: 400px;
  background-color: #eeeeee;
}

p {
  color: white;
  font-size: 18px;
  top: 0;
  left: 0;
  right: 0;
}
p:nth-child(1) {
  background-color: red;
  position: sticky;
  top: 0;
  
}
p:nth-child(2) {
  background-color: blue;

}
p:nth-child(3) {
  background-color: green;
  height: 1000px;
}
</style>
