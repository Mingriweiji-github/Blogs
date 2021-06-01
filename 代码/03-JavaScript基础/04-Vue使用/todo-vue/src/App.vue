<template>
  <div id="app">
      <!-- <h1>My ToTo List</h1>
      <to-do-form></to-do-form>
      <ul>
        <li v-for="item in ToDoItems" :key="item.id">
          <to-do-item :label="item.label" :done="item.done"> </to-do-item>
        </li>
      </ul> -->

      <div id="card">
          <!-- <label for="智慧服务" id="card_tip"></label> -->
          <img class="card_image" src="./assets/logo.png" alt="Vue logo">
          <div class="card_container">
            <div>
              <div class="card_item_row">
                <div class="card_item card_item_row_first">Vue</div>
                <div class="card_item card_item_row_second">1.0</div>
              </div>
              <div class="card_item_row">
                <div class="card_item card_item_row_first">Vue</div>
                <div class="card_item card_item_row_second">2.0</div>
              </div>
              <div class="card_item_row">
                <div class="card_item card_item_row_first">Vue</div>
                <div class="card_item card_item_row_second">3.0</div>
              </div>
            </div>

            <div>
              <div class="card_item_row card_second_row">2014-02</div>
              <div class="card_item_row card_second_row">2016-10</div>
              <div class="card_item_row card_second_row">2020-09</div>
            </div>

        </div>
      </div>

      <div class="list_title">收入排名</div>
      <!-- 单列表 -->
      <div class="list_row">
          <div class="list_row_card">
            <div class="list_row_container">
              <div class="list_row_first">
                    <div class="list_row_first_start">01. 北京地区</div>
                    <div class="list_row_first_end">
                        <div class="list_row_first_end_first">88.5</div>
                        <div class="list_row_first_end_second">%</div>
                    </div>
              </div>
              <div class="list_row_second">
                    <div class="list_row_second_item">腾讯1</div>
                    <div class="list_row_second_item list_row_second_item2">头条2</div>
                    <div class="list_row_second_item">阿里3</div>
              </div>
            </div>
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
.card_image {
  margin-top: 15px;
  margin-bottom: 10px;
  height: 90px;
  width: 90px;
  display: inline-flex;
  justify-content: center;
  align-items: center;
}
#card_tip {
  top: 15px;
  background: orange;
  height: 21px;
  width: 100px;
  float: left;
}
/* CSS三等分方式一 width: calc(100% / 3) */
.card_container {
  display: column;
  width: 100%;
}

.card_item_row {
  float: left;
  width: calc(100% / 3);
  background-color: rebeccapurple;
}
/* CSS三等分-两排row */
.card_item {
  display: inline-flex;
  flex-direction: columns;
  align-items: flex-end;
  justify-content: center;
}

.card_item_row_first {
  color: white;
  font-size: 19px;
}
.card_item_row_second {
  color: white;
  font-size: 12px;
}

.card_second_row {
  color: #B9DAFF;
  font-size: 12px;
}

/* List title */
.list_title {
  float: left;
  margin-left: 18px;
  margin-bottom: 16px;
  font-size: 18px;
  color:#333333;
}
/* List */
.list_row {
  float: left;
  width: 100%;
}
.list_row_card {
  background: #f5f7fc;
  margin-left: 18px;
  margin-right: 18px;
}
.list_row_container {
  display: flex;
  flex-direction: column;
  justify-content: left;
  color: purple;
}
.list_row_first {
  margin-top: 15px;
  margin-left: 15px;
  margin-bottom: 5px;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}
.list_row_second {
  margin-left: 15px;
  margin-bottom: 15px;
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
}
/* row */
.list_row_first_start {
  color: #333333;
  font-size: 16px;
}
.list_row_first_end {
  display: inline-flex;
  flex-direction: columns;
  align-items: flex-end;
  justify-content: center;
}
/* row first */
.list_row_first_end_first {
  color: #333333;
  font-size: 19px;
}
/* row second */
.list_row_first_end_second {
  margin-right: 25px;
  margin-left: 6px;
  color: #666666;
  font-size: 16px;
}

/* column */
.list_row_second_item {
  color: #999999;
  font-size: 12px;
}
.list_row_second_item2 {
  margin-left: 20px;
  margin-right: 20px;
}

</style>