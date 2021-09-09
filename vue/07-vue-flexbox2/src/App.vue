<template>
  <div id="app">
    <div class="main">
      <div class="flex1">前端小课flex item属性</div>
      <div class="flex2">FlexBox World</div>
      <div class="flex3">Flex布局33</div>
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
#app {
  margin: 0;
  padding: 0;
  /* background-color: purple; */
}
.main {
  background-color: wheat;
  width: 600px;
  height: 200px;
  display: flex;
}


div div {
  height: 40px;
  font-size: 28px;
  text-align: center;
  flex-basis: 0;
  flex-grow: 1;
}
.flex1 {
  background-color: red;
  
}

.flex2 {
  background-color: green;
}
.flex3 {
  background-color: blue;
}






</style>
