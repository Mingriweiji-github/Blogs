<template>
  <div id="app">
      <h1>My ToTo List</h1>
      <to-do-form></to-do-form>
      <ul>
        <li v-for="item in ToDoItems" :key="item.id">
          <to-do-item :label="item.label" :done="item.done"> </to-do-item>
        </li>
      </ul>
 
  </div>
</template>

<script>
import ToDoItem from "./components/ToDoItem.vue";
import uniqueId from "lodash.uniqueid";
import ToDoForm from "./components/ToDoForm.vue";
export default {
  name: 'app',
  components: {
    ToDoItem,
    ToDoForm,
  },
  data() {
    return {
      ToDoItems: [
        { id: uniqueId("todo-"), label: "Learn Vue", done: false },
        { id: uniqueId("todo-"), label: "Create a Vue Project with CLI", done: true },
        { id: uniqueId("todo-"), label: "Have Fun", done: true },
        { id: uniqueId("todo-"), label: "Create a todo List", done: false },
        { id: uniqueId("todo-"), label: "Time:2021-05-31 14:58:09", done: true }
      ]
    };
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
