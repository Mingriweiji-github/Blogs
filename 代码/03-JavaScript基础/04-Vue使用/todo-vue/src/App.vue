<template>
  <div id="app">
      <!-- <h1>My ToTo List</h1>
      <to-do-form></to-do-form>
      <ul>
        <li v-for="item in ToDoItems" :key="item.id">
          <to-do-item :label="item.label" :done="item.done"> </to-do-item>
        </li>
      </ul> -->
      <div class="blank">

      </div>
      <div id="card">
        <label id="cardTitle" for="智慧服务"></label>
        <img id="ball" src="./assets/logo.png" alt="Vue logo">

        <div class="card_header_container">
          <div class="header_title">重大事故1</div>
          <div class="header_title">重大事故2</div>
          <div class="header_title">重大事故3</div>
        </div>
      </div>

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
#blank {
  height: 50px;
  width: 100%;
  background: rebeccapurple;
}
#card {
  background: blue;
  height: 20rem;
  margin: 2rem 0 4rem 0;
  padding: 1rem;
  padding-top: 50;
  position: relative;
  box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.2), 0 2.5rem 5rem 0 rgba(0, 0, 0, 0.1);
}
#ball {
  top: 15px;
  height: 50px;
  width: 50px;
  
}
#cardTitle {
  top: 15px;
  background: orange;
  height: 21px;
  width: 100px;
  float: left;
}
#card_header_container {
  height: 20px;
  max-width: 100%;
  display: flex;
}
#header_title {
  background: red;
  flex: 1;
  height: 20px;
}

.card_header_container .header_title:nth-of-type(1) {
  padding-right: 10px;
}
.card_header_container .header_title:nth-of-type(2) {
  padding-left: 10px;
  padding-right: 10px;
}
.card_header_container .header_title:nth-of-type(3) {
  padding-left: 10px;
}

</style>
