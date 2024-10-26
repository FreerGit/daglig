<script setup>
import { ref } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'

</script>

<script>
import { CalendarHeatmap } from "vue3-calendar-heatmap";

export default {
  name: "GitHubHeatmap",
  components: {
    CalendarHeatmap,
  },
  data() {
    return {
      heatmapData: [
        { date: "2018-9-21", count: 6 },
        { date: "2018-9-22", count: 6 },
      ],
      username: "mrbigoudi",
    };
  },
};
</script>


<template>

  <div class="heatmap">
      <h1>122432</h1>
      <CalendarHeatmap
        :values="[
          { date: '2018-9-21', count: 6 },
          { date: '2018-9-22', count: 6 },
        ]"
        :end-date="'2018-12-22'"
        :dark-mode="true"
        tooltip-unit="actions"
      />
      <h1>122432</h1>

    </div>

  <header>
    <img alt="Vue logo" class="logo" src="@/assets/logo.svg" width="125" height="125" />
    
    <div class="wrapper">
      <HelloWorld msg="You did it!" />
      
      <nav>
        <RouterLink to="/">Home</RouterLink>
        <RouterLink to="/about">About</RouterLink>
      </nav>
    </div>
  </header>
  
  <RouterView />

</template>

<style scoped>
header {
  line-height: 1.5;
  max-height: 100vh;
}

.logo {
  display: block; 
  margin: 0 auto 2rem;
}

nav {
  width: 100%;
  font-size: 12px;
  text-align: center;
  margin-top: 2rem;
}

nav a.router-link-exact-active {
  color: var(--color-text);
}

nav a.router-link-exact-active:hover {
  background-color: transparent;
}

nav a {
  display: inline-block;
  padding: 0 1rem;
  border-left: 1px solid var(--color-border);
}

nav a:first-of-type {
  border: 0;
}

@media (min-width: 1024px) {
  header {
    display: flex;
    place-items: center;
    padding-right: calc(var(--section-gap) / 2);
  }

  .logo {
    margin: 0 2rem 0 0;
  }

  header .wrapper {
    display: flex;
    place-items: flex-start;
    flex-wrap: wrap;
  }

  nav {
    text-align: left;
    margin-left: -1rem;
    font-size: 1rem;

    padding: 1rem 0;
    margin-top: 1rem;
  }
}
</style>
