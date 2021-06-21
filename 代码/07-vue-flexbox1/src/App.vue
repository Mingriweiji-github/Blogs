<template>
  <div id="app">
    <div class="main">
      <div class="flex1">Flex布局1</div>
      <div class="flex2">Flex布局2</div>
      <div class="flex4">插入Flex布局4插入Flex布局4插入Flex布局4插入Flex布局4</div>
      <div class="flex3">Flex布局第3</div>
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
  width: 100%;
  height: 200px;
  display: flex;
  /* flex-direction: row;
  flex-wrap: wrap; */
  flex-flow: row wrap;
  align-content: space-between;
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
  
/* .space-around {
  justify-content: space-around;
}

.center {
  justify-content: center;
}

.end {
  justify-content: flex-end;
} */




</style>
