# 05_Python-Advanced-Design-Architecture-Part5

**Learning Level**: Advanced  
**Prerequisites**: Performance optimization (Part 4), design pattern fundamentals, software architecture  
**Estimated Time**: Part 5 of 5 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master advanced architectural patterns for scalable Python applications
- Implement enterprise design patterns with dependency injection and event systems
- Design plugin architectures with dynamic module loading and extensibility
- Build production-ready frameworks with proper abstraction layers and interfaces

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

**Advanced Architecture** involves creating flexible, maintainable systems using proven design patterns. **Enterprise Patterns** include dependency injection, observer pattern, and plugin systems. **Framework Design** requires proper abstraction layers, interface segregation, and extensibility mechanisms.

**Architectural Principles**:

- **Dependency Injection**: Invert control for testable, flexible code
- **Plugin Architecture**: Dynamic extension without core modifications  
- **Event-Driven Design**: Loose coupling through message passing
- **Factory Patterns**: Abstract object creation for flexibility

### Core Implementation (6 minutes)

```python
# ✅ Advanced Dependency Injection Framework
import abc
import inspect
import threading
from contextlib import contextmanager
from dataclasses import dataclass
from enum import Enum
from typing import Any, Callable, Dict, Generic, List, Optional, Protocol, Type, TypeVar, Union
import weakref
import importlib
import logging

T = TypeVar('T')

class Lifecycle(Enum):
    """Service lifecycle management options."""
    SINGLETON = "singleton"
    TRANSIENT = "transient" 
    SCOPED = "scoped"

@dataclass
class ServiceRegistration:
    """Service registration metadata."""
    service_type: Type
    implementation: Union[Type, Callable]
    lifecycle: Lifecycle
    dependencies: List[str]
    factory: Optional[Callable] = None

class DIContainer:
    """Production-ready dependency injection container with lifecycle management."""
    
    def __init__(self):
        self._registrations: Dict[Type, ServiceRegistration] = {}
        self._singletons: Dict[Type, Any] = {}
        self._scoped_instances: Dict[int, Dict[Type, Any]] = {}
        self._lock = threading.RLock()
        self._scope_counter = 0
        
    def register(self, service_type: Type, implementation: Type = None, 
                 lifecycle: Lifecycle = Lifecycle.TRANSIENT,
                 factory: Callable = None) -> 'DIContainer':
        """Register service with container."""
        
        if implementation is None:
            implementation = service_type
        
        # Analyze dependencies
        dependencies = self._analyze_dependencies(implementation if not factory else factory)
        
        registration = ServiceRegistration(
            service_type=service_type,
            implementation=implementation,
            lifecycle=lifecycle,
            dependencies=dependencies,
            factory=factory
        )
        
        with self._lock:
            self._registrations[service_type] = registration
        
        return self
    
    def register_singleton(self, service_type: Type, implementation: Type = None) -> 'DIContainer':
        """Register service as singleton."""
        return self.register(service_type, implementation, Lifecycle.SINGLETON)
    
    def register_factory(self, service_type: Type, factory: Callable, 
                        lifecycle: Lifecycle = Lifecycle.TRANSIENT) -> 'DIContainer':
        """Register service with custom factory function."""
        return self.register(service_type, factory=factory, lifecycle=lifecycle)
    
    def resolve(self, service_type: Type, scope_id: int = None) -> Any:
        """Resolve service instance with dependency injection."""
        
        with self._lock:
            if service_type not in self._registrations:
                raise ValueError(f"Service type {service_type} not registered")
            
            registration = self._registrations[service_type]
            
            # Handle singleton lifecycle
            if registration.lifecycle == Lifecycle.SINGLETON:
                if service_type not in self._singletons:
                    instance = self._create_instance(registration, scope_id)
                    self._singletons[service_type] = instance
                return self._singletons[service_type]
            
            # Handle scoped lifecycle
            elif registration.lifecycle == Lifecycle.SCOPED:
                if scope_id is None:
                    raise ValueError("Scope ID required for scoped services")
                
                if scope_id not in self._scoped_instances:
                    self._scoped_instances[scope_id] = {}
                
                if service_type not in self._scoped_instances[scope_id]:
                    instance = self._create_instance(registration, scope_id)
                    self._scoped_instances[scope_id][service_type] = instance
                
                return self._scoped_instances[scope_id][service_type]
            
            # Handle transient lifecycle
            else:
                return self._create_instance(registration, scope_id)
    
    def _create_instance(self, registration: ServiceRegistration, scope_id: int = None) -> Any:
        """Create service instance with dependency resolution."""
        
        if registration.factory:
            # Use custom factory
            dependencies = self._resolve_dependencies(registration.dependencies, scope_id)
            return registration.factory(**dependencies)
        
        # Use constructor injection
        dependencies = self._resolve_dependencies(registration.dependencies, scope_id)
        
        try:
            return registration.implementation(**dependencies)
        except TypeError as e:
            raise RuntimeError(f"Failed to create instance of {registration.implementation}: {e}")
    
    def _analyze_dependencies(self, target: Callable) -> List[str]:
        """Analyze constructor/function dependencies."""
        
        sig = inspect.signature(target)
        dependencies = []
        
        for param_name, param in sig.parameters.items():
            if param_name == 'self':
                continue
            
            if param.annotation != inspect.Parameter.empty:
                dependencies.append(param_name)
        
        return dependencies
    
    def _resolve_dependencies(self, dep_names: List[str], scope_id: int = None) -> Dict[str, Any]:
        """Resolve all dependencies for a service."""
        
        dependencies = {}
        
        for dep_name in dep_names:
            # Find registered service by parameter name or type
            for service_type, registration in self._registrations.items():
                if (service_type.__name__.lower() == dep_name.lower() or 
                    registration.implementation.__name__.lower() == dep_name.lower()):
                    dependencies[dep_name] = self.resolve(service_type, scope_id)
                    break
        
        return dependencies
    
    @contextmanager
    def scope(self):
        """Create service scope for scoped lifetime management."""
        scope_id = self._scope_counter
        self._scope_counter += 1
        
        try:
            yield scope_id
        finally:
            # Clean up scoped instances
            with self._lock:
                self._scoped_instances.pop(scope_id, None)

# ✅ Advanced Plugin Architecture System
class PluginInterface(abc.ABC):
    """Base interface for plugin system."""
    
    @abc.abstractmethod
    def get_name(self) -> str:
        """Get plugin name."""
        pass
    
    @abc.abstractmethod
    def get_version(self) -> str:
        """Get plugin version."""
        pass
    
    @abc.abstractmethod
    def initialize(self, context: Dict[str, Any]) -> bool:
        """Initialize plugin with context."""
        pass
    
    @abc.abstractmethod
    def execute(self, *args, **kwargs) -> Any:
        """Execute plugin functionality."""
        pass

class PluginManager:
    """Dynamic plugin loading and lifecycle management."""
    
    def __init__(self):
        self._plugins: Dict[str, PluginInterface] = {}
        self._plugin_configs: Dict[str, Dict[str, Any]] = {}
        self._hooks: Dict[str, List[Callable]] = {}
        self._lock = threading.Lock()
        self.logger = logging.getLogger(__name__)
    
    def register_plugin(self, plugin: PluginInterface, config: Dict[str, Any] = None) -> bool:
        """Register plugin instance."""
        
        plugin_name = plugin.get_name()
        
        with self._lock:
            if plugin_name in self._plugins:
                self.logger.warning(f"Plugin {plugin_name} already registered")
                return False
            
            # Initialize plugin
            context = config or {}
            context['plugin_manager'] = self
            
            if plugin.initialize(context):
                self._plugins[plugin_name] = plugin
                self._plugin_configs[plugin_name] = config or {}
                
                self.logger.info(f"Plugin {plugin_name} v{plugin.get_version()} registered successfully")
                
                # Trigger registration hooks
                self._trigger_hooks('plugin_registered', plugin_name, plugin)
                return True
            else:
                self.logger.error(f"Failed to initialize plugin {plugin_name}")
                return False
    
    def load_plugin_from_module(self, module_name: str, class_name: str, 
                               config: Dict[str, Any] = None) -> bool:
        """Dynamically load plugin from module."""
        
        try:
            # Import module
            module = importlib.import_module(module_name)
            
            # Get plugin class
            plugin_class = getattr(module, class_name)
            
            # Verify interface compliance
            if not issubclass(plugin_class, PluginInterface):
                raise TypeError(f"{class_name} must implement PluginInterface")
            
            # Create and register plugin
            plugin = plugin_class()
            return self.register_plugin(plugin, config)
            
        except Exception as e:
            self.logger.error(f"Failed to load plugin {module_name}.{class_name}: {e}")
            return False
    
    def unregister_plugin(self, plugin_name: str) -> bool:
        """Unregister plugin and clean up resources."""
        
        with self._lock:
            if plugin_name not in self._plugins:
                return False
            
            plugin = self._plugins.pop(plugin_name)
            self._plugin_configs.pop(plugin_name, None)
            
            # Trigger unregistration hooks
            self._trigger_hooks('plugin_unregistered', plugin_name, plugin)
            
            self.logger.info(f"Plugin {plugin_name} unregistered")
            return True
    
    def execute_plugin(self, plugin_name: str, *args, **kwargs) -> Any:
        """Execute specific plugin."""
        
        with self._lock:
            if plugin_name not in self._plugins:
                raise ValueError(f"Plugin {plugin_name} not found")
            
            plugin = self._plugins[plugin_name]
        
        try:
            result = plugin.execute(*args, **kwargs)
            self._trigger_hooks('plugin_executed', plugin_name, result)
            return result
        
        except Exception as e:
            self.logger.error(f"Plugin {plugin_name} execution failed: {e}")
            self._trigger_hooks('plugin_error', plugin_name, e)
            raise
    
    def register_hook(self, event_name: str, callback: Callable):
        """Register event hook for plugin lifecycle events."""
        
        if event_name not in self._hooks:
            self._hooks[event_name] = []
        
        self._hooks[event_name].append(callback)
    
    def _trigger_hooks(self, event_name: str, *args, **kwargs):
        """Trigger registered hooks for event."""
        
        if event_name in self._hooks:
            for callback in self._hooks[event_name]:
                try:
                    callback(*args, **kwargs)
                except Exception as e:
                    self.logger.error(f"Hook callback failed for {event_name}: {e}")
    
    def get_plugin_info(self) -> Dict[str, Dict[str, Any]]:
        """Get information about all registered plugins."""
        
        with self._lock:
            return {
                name: {
                    'name': plugin.get_name(),
                    'version': plugin.get_version(),
                    'config': self._plugin_configs.get(name, {})
                }
                for name, plugin in self._plugins.items()
            }

# ✅ Event-Driven Architecture System
class Event:
    """Base event class for event-driven architecture."""
    
    def __init__(self, event_type: str, data: Any = None, metadata: Dict[str, Any] = None):
        self.event_type = event_type
        self.data = data
        self.metadata = metadata or {}
        self.timestamp = time.time()
        self.event_id = f"{event_type}_{int(self.timestamp * 1000000)}"

class EventBus:
    """Production-ready event bus with async support and error handling."""
    
    def __init__(self):
        self._handlers: Dict[str, List[Callable]] = {}
        self._global_handlers: List[Callable] = []
        self._error_handlers: List[Callable] = []
        self._lock = threading.RLock()
        self._event_history: deque = deque(maxlen=1000)
        self.logger = logging.getLogger(__name__)
    
    def subscribe(self, event_type: str, handler: Callable) -> Callable:
        """Subscribe to specific event type."""
        
        with self._lock:
            if event_type not in self._handlers:
                self._handlers[event_type] = []
            
            self._handlers[event_type].append(handler)
        
        self.logger.debug(f"Subscribed handler to {event_type}")
        
        # Return unsubscribe function
        def unsubscribe():
            with self._lock:
                if event_type in self._handlers and handler in self._handlers[event_type]:
                    self._handlers[event_type].remove(handler)
        
        return unsubscribe
    
    def subscribe_global(self, handler: Callable) -> Callable:
        """Subscribe to all events."""
        
        with self._lock:
            self._global_handlers.append(handler)
        
        def unsubscribe():
            with self._lock:
                if handler in self._global_handlers:
                    self._global_handlers.remove(handler)
        
        return unsubscribe
    
    def subscribe_errors(self, error_handler: Callable):
        """Subscribe to event handling errors."""
        
        with self._lock:
            self._error_handlers.append(error_handler)
    
    def publish(self, event: Event):
        """Publish event to all subscribers."""
        
        # Store in history
        self._event_history.append({
            'event_id': event.event_id,
            'event_type': event.event_type,
            'timestamp': event.timestamp,
            'data_size': len(str(event.data)) if event.data else 0
        })
        
        # Get handlers to notify
        handlers_to_notify = []
        
        with self._lock:
            # Specific event type handlers
            if event.event_type in self._handlers:
                handlers_to_notify.extend(self._handlers[event.event_type])
            
            # Global handlers
            handlers_to_notify.extend(self._global_handlers)
        
        # Notify handlers
        for handler in handlers_to_notify:
            try:
                handler(event)
            except Exception as e:
                self.logger.error(f"Event handler failed for {event.event_type}: {e}")
                
                # Notify error handlers
                for error_handler in self._error_handlers:
                    try:
                        error_handler(event, e)
                    except Exception as error_handler_error:
                        self.logger.critical(f"Error handler failed: {error_handler_error}")
        
        self.logger.debug(f"Published event {event.event_id} to {len(handlers_to_notify)} handlers")
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get event bus statistics."""
        
        with self._lock:
            handler_counts = {event_type: len(handlers) for event_type, handlers in self._handlers.items()}
            
            return {
                'total_subscriptions': sum(handler_counts.values()),
                'global_handlers': len(self._global_handlers),
                'error_handlers': len(self._error_handlers),
                'event_types': list(self._handlers.keys()),
                'recent_events': len(self._event_history),
                'handler_counts': handler_counts
            }

# ✅ Production Usage Examples
# Example Plugin Implementation
class DataProcessorPlugin(PluginInterface):
    """Example data processing plugin."""
    
    def __init__(self):
        self.config = {}
        self.initialized = False
    
    def get_name(self) -> str:
        return "data_processor"
    
    def get_version(self) -> str:
        return "1.0.0"
    
    def initialize(self, context: Dict[str, Any]) -> bool:
        """Initialize plugin with configuration."""
        self.config = context.get('config', {})
        self.initialized = True
        return True
    
    def execute(self, data: List[Any]) -> Dict[str, Any]:
        """Process data and return results."""
        if not self.initialized:
            raise RuntimeError("Plugin not initialized")
        
        # Simulate data processing
        processed_count = len(data)
        
        return {
            'processed_items': processed_count,
            'plugin': self.get_name(),
            'version': self.get_version()
        }

# Example Service Classes for DI
class DatabaseService:
    """Example database service."""
    
    def __init__(self):
        self.connected = True
    
    def query(self, sql: str) -> Dict[str, Any]:
        return {'result': f'Query: {sql}', 'rows': 42}

class LoggingService:
    """Example logging service."""
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
    
    def log(self, message: str, level: str = 'INFO'):
        getattr(self.logger, level.lower())(message)

class BusinessService:
    """Example business service with dependencies."""
    
    def __init__(self, databaseservice: DatabaseService, loggingservice: LoggingService):
        self.db = databaseservice
        self.logger = loggingservice
    
    def process_business_logic(self, data: str) -> str:
        self.logger.log(f"Processing: {data}")
        result = self.db.query(f"SELECT * FROM business WHERE data='{data}'")
        return f"Processed: {result}"

# ✅ Advanced Usage Demonstration
def demonstrate_architecture_patterns():
    """Demonstrate advanced architecture patterns in production."""
    
    # Setup logging
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
    
    # 1. Dependency Injection Demo
    print("=== Dependency Injection Demo ===")
    
    container = DIContainer()
    
    # Register services
    container.register_singleton(DatabaseService)
    container.register_singleton(LoggingService)
    container.register(BusinessService, lifecycle=Lifecycle.TRANSIENT)
    
    # Resolve and use services
    business_service = container.resolve(BusinessService)
    result = business_service.process_business_logic("test_data")
    print(f"Business service result: {result}")
    
    # 2. Plugin System Demo
    print("\n=== Plugin System Demo ===")
    
    plugin_manager = PluginManager()
    
    # Register plugin
    data_plugin = DataProcessorPlugin()
    plugin_manager.register_plugin(data_plugin, config={'batch_size': 100})
    
    # Execute plugin
    test_data = [1, 2, 3, 4, 5]
    plugin_result = plugin_manager.execute_plugin('data_processor', test_data)
    print(f"Plugin result: {plugin_result}")
    
    # 3. Event-Driven Architecture Demo
    print("\n=== Event-Driven Architecture Demo ===")
    
    event_bus = EventBus()
    
    # Subscribe to events
    def handle_user_action(event: Event):
        print(f"Handling user action: {event.data}")
    
    def handle_system_event(event: Event):
        print(f"System event: {event.event_type} - {event.data}")
    
    unsubscribe1 = event_bus.subscribe('user_action', handle_user_action)
    unsubscribe2 = event_bus.subscribe_global(handle_system_event)
    
    # Publish events
    event_bus.publish(Event('user_action', {'user_id': 123, 'action': 'login'}))
    event_bus.publish(Event('system_startup', {'version': '1.0.0'}))
    
    # Get statistics
    stats = event_bus.get_statistics()
    print(f"Event bus stats: {stats}")
    
    print("\n=== Architecture Patterns Demo Complete ===")

if __name__ == "__main__":
    import time
    from collections import deque
    demonstrate_architecture_patterns()
```

### Key Takeaways (2 minutes)

#### **🎯 Advanced Architecture Mastery**

**Dependency Injection**: Production-ready DI container with lifecycle management (singleton, transient, scoped)

**Plugin Architecture**: Dynamic plugin loading with interfaces and lifecycle hooks

**Event-Driven Design**: Robust event bus with error handling and global subscriptions

#### **⚡ Enterprise Framework Patterns**

- **Service Registration**: Flexible service binding with automatic dependency resolution
- **Plugin Interface**: Standardized plugin contracts with version management
- **Event System**: Decoupled communication with comprehensive error handling
- **Production Monitoring**: Statistics tracking and performance analysis

**🎉 PYTHON ADVANCED PATTERNS COMPLETE!** 5/5 modules covering enterprise-grade Python architecture! 🚀

**🔥 Ready for next domain conversion**: Design Principles, Data Science, or DevOps!
