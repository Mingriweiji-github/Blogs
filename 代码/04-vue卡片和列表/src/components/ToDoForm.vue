<template>
    <form>
        <label for="new-todo-input">
            What needs to be done?
        </label>
        <input 
            type="text"
            id="new-todo-input"
            name="new-todo"
            autocomplete="off"
        />

        <button type="submit">
            Add
        </button>
    </form>
</template>

<script>
export default { };
</script>