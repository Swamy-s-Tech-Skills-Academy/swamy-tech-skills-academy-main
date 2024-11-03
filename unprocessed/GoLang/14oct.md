# Developing Web API in Go Lang

When developing a simple web API in Go, you have several options for routing and handling HTTP requests. Here are some of the most popular options:

## 1. **net/http (Default Go HTTP package)**

- **Overview**: The standard library's `net/http` package is a lightweight, built-in solution that provides everything needed to serve HTTP requests without external dependencies.
- **When to use**: Ideal for small, simple projects or when you want full control over the HTTP server without relying on third-party libraries.

## 2. **Gorilla Mux**

- **Overview**: `Gorilla Mux` is a powerful URL router and dispatcher that is more flexible than `net/http`. It allows for complex routing, including variables in URLs, regular expressions, and subrouters.
- **When to use**: Suitable for more complex routing needs while maintaining a balance between simplicity and flexibility. It’s a widely used and trusted library.

## 3. **Gin**

- **Overview**: Gin is a lightweight and fast web framework that includes a router, middleware, and useful utilities for building APIs. It is known for its performance due to its low memory footprint.
- **When to use**: Use Gin if you need high performance, want minimalistic code, and require middleware support like logging, error handling, and more. It's popular for RESTful APIs.

## 4. **Echo**

- **Overview**: Echo is another high-performance, minimalist web framework similar to Gin. It provides a clean, elegant API and is optimized for performance. It also supports middleware and websockets.
- **When to use**: Choose Echo when you want performance and clean design, along with a framework that includes features like group routing, data binding, and middleware support.

## 5. **Fiber**

- **Overview**: Fiber is an Express.js-inspired web framework built on top of `fasthttp`, a fast HTTP engine in Go. It is very lightweight and performant, often considered one of the fastest Go web frameworks.
- **When to use**: Ideal for developers looking for a familiar framework (if they have used Express.js) with a focus on performance and simplicity.

## 6. **Chi**

- **Overview**: Chi is a lightweight, idiomatic, and composable router for building HTTP services in Go. It focuses on providing a simple but powerful API for working with HTTP routing.
- **When to use**: Chi is excellent for writing RESTful APIs that need composability and middlewares, without much overhead. It’s simple but robust, and focuses on low memory consumption.

## 7. **Beego**

- **Overview**: Beego is a full-featured Go web application framework with an MVC architecture. It includes routing, an ORM, and middleware out of the box.
- **When to use**: Ideal when you want a full-stack framework with more than just routing, including things like ORM and template support.

## 8. **Iris**

- **Overview**: Iris is a comprehensive web framework that focuses on performance and provides a wide range of features including routing, middleware, websockets, and more.
- **When to use**: Use Iris if you want an all-in-one solution with extensive features like real-time communication and internationalization.

## 9. **Revel**

- **Overview**: Revel is a fully-featured Go framework that offers a higher-level abstraction compared to frameworks like Gin or Echo. It provides generators, an ORM, and comes with middleware and other utilities.
- **When to use**: Revel is ideal for developers who are familiar with frameworks like Ruby on Rails or Django, as it follows a similar pattern and offers more out-of-the-box functionality.

## 10. **Buffalo**

- **Overview**: Buffalo is a rapid development web framework that includes routing, testing, templating, and more. It is similar to frameworks like Rails or Laravel but tailored to Go.
- **When to use**: If you want a Rails-like experience in Go, Buffalo provides an ecosystem that includes everything from routing to ORM and is focused on speed of development.

## Summary of Choices:

- For **simple APIs**, use `net/http`, `Gorilla Mux`, or **Gin**.
- For **high-performance APIs**, consider **Gin**, **Echo**, or **Fiber**.
- If you need **full-stack** or **MVC frameworks**, try **Beego**, **Revel**, or **Buffalo**.

Each framework or package has its strengths depending on the complexity, performance needs, and developer experience.

---

## Q1

> Difference between A. Use default ServeMux, B. Servermux

The terms **"default ServeMux"** and **"ServeMux"** in Go are often used interchangeably but refer to slightly different concepts. Let’s break down the difference between the two:

### A. Default `ServeMux` (from `http.DefaultServeMux`)

- **What it is**: Go’s standard library provides a global, **default instance** of the `ServeMux` multiplexer, which is automatically used if you don't create a custom one. This is referred to as the **`http.DefaultServeMux`**.
- **Usage**: When you use functions like `http.HandleFunc()` or `http.ListenAndServe()`, and don’t explicitly specify a multiplexer, the Go runtime automatically registers handlers to the **default `ServeMux`** (`http.DefaultServeMux`).
- **Advantages**:
  - Convenient for small, simple applications where you don’t need custom routing logic.
  - You don't need to manually create or manage an instance of `ServeMux`—Go does it for you.
- **Disadvantages**:
  - Lack of flexibility, as it’s global and can't be reused in isolation.
  - Can lead to handler collisions if multiple components in your app unknowingly use it.

### B. Custom `ServeMux` (`http.ServeMux`)

- **What it is**: `ServeMux` is a **custom instance** of the multiplexer provided by Go’s `net/http` package. It is a more explicit and flexible approach where you can create your own instance of `ServeMux` and control its behavior.
- **Usage**: You create a new instance using `http.NewServeMux()` and explicitly register routes and handlers. This gives you greater control over routing in your application.
  ```go
  mux := http.NewServeMux()
  mux.HandleFunc("/route", handlerFunc)
  http.ListenAndServe(":8080", mux)
  ```
- **Advantages**:
  - Allows for multiple custom multiplexers, making it easier to separate concerns within the application.
  - You have more control over routing and configuration.
- **Disadvantages**: Slightly more setup required compared to the default `ServeMux`, but this is minor.

### Key Differences:

1. **Instance**:
   - Default `ServeMux` is a global instance (`http.DefaultServeMux`), while custom `ServeMux` is explicitly created using `http.NewServeMux()`.
2. **Flexibility**:

   - Using the default is simpler but limits control. Custom `ServeMux` allows for flexibility and modularity (you can create several instances and control them individually).

3. **Scalability**:
   - Default `ServeMux` is fine for smaller projects, but as complexity grows, using a custom `ServeMux` helps in isolating routes, managing different HTTP servers, and avoiding potential conflicts in handler registration.

In summary:

- **Use default `ServeMux`** if you want simplicity for small applications.
- **Use a custom `ServeMux`** (`http.NewServeMux()`) for better control, scalability, and modularity in larger applications.
