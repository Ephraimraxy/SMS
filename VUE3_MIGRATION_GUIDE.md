# Vue 3 Migration Guide for SMS Project

## ⚠️ Important: Vue 2 → Vue 3 Migration Required

The SMS project has been updated from Vue 2.5.7 to Vue 3.4.31. This is a **major version upgrade** that requires code changes.

## 🔄 Key Changes

### 1. **Component Registration**

**Vue 2:**
```javascript
Vue.component('my-component', {
  // ...
})
```

**Vue 3:**
```javascript
import { createApp } from 'vue'
const app = createApp({})
app.component('my-component', {
  // ...
})
```

### 2. **Event Handling**

**Vue 2:**
```vue
<button @click="$emit('my-event', data)">Click</button>
```

**Vue 3:**
```vue
<button @click="emit('my-event', data)">Click</button>
```

In script:
```javascript
import { defineEmits } from 'vue'
const emit = defineEmits(['my-event'])
```

### 3. **Props**

**Vue 2:**
```javascript
props: ['title', 'content']
```

**Vue 3:**
```javascript
import { defineProps } from 'vue'
const props = defineProps(['title', 'content'])
```

### 4. **v-model**

**Vue 2:**
```vue
<input v-model="value" />
```

**Vue 3:** (Same, but multiple v-models supported)
```vue
<input v-model="value" />
<input v-model:title="title" />
```

### 5. **Filters Removed**

**Vue 2:**
```vue
{{ message | capitalize }}
```

**Vue 3:** (Use computed properties or methods)
```vue
{{ capitalize(message) }}
```

### 6. **Global API Changes**

**Vue 2:**
```javascript
Vue.use(plugin)
Vue.mixin(mixin)
```

**Vue 3:**
```javascript
import { createApp } from 'vue'
const app = createApp({})
app.use(plugin)
app.mixin(mixin)
```

## 📝 Migration Steps

1. **Update resources/js/app.js:**
   ```javascript
   // Vue 2
   // import Vue from 'vue'
   
   // Vue 3
   import { createApp } from 'vue'
   import App from './App.vue'
   
   const app = createApp(App)
   app.mount('#app')
   ```

2. **Update Component Files:**
   - Change `export default { ... }` to use Composition API or Options API
   - Update event emissions
   - Replace filters with methods/computed

3. **Update Bootstrap Vue (if used):**
   - Bootstrap Vue doesn't support Vue 3
   - Consider migrating to BootstrapVue Next or Bootstrap 5 with custom components

## 🔍 Files to Check

- `resources/js/app.js`
- `resources/js/components/**`
- `resources/views/**` (if Vue components are used in Blade templates)

## 📚 Resources

- [Vue 3 Migration Guide](https://v3-migration.vuejs.org/)
- [Vue 3 Documentation](https://vuejs.org/)
- [Composition API Guide](https://vuejs.org/guide/extras/composition-api-faq.html)

## ⚡ Quick Fixes

If you need to temporarily keep Vue 2 compatibility, you can:

1. Install Vue 2 compatibility build:
   ```bash
   npm install vue@^2.7.16
   ```

2. But this is **not recommended** for long-term. Migrate to Vue 3 for better performance and features.

---

**Note:** This migration is required for the updated dependencies to work properly.




