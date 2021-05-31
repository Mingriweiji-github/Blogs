<template>
  <div id="app">
    <!-- <img alt="Vue logo" src="./assets/logo.png">  -->
    <!-- <HelloWorld msg="Welcome to Your Vue.js App"/> -->
    <h1>Todo List</h1>
       <li>
        <to-do-item label="My Todo Item" :done="true"> </to-do-item>
      </li>
  </div>
</template>

<script>
// import { component } from 'vue/types/umd';
// import HelloWorld from './components/HelloWorld.vue'
import ToDoItem from "./components/ToDoItem.vue";

export default {
  name: 'App',
  components: {
    ToDoItem
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
