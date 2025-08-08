# 03_Agent-Development-Fundamentals

**Learning Level**: Intermediate  
**Prerequisites**: AI Agent fundamentals, agent architectures, Python programming  
**Estimated Time**: 150 minutes  

## 🎯 Learning Objectives

By the end of this content, you will:

- Build functional AI agents using popular frameworks (LangChain, CrewAI, Semantic Kernel)
- Implement core agent capabilities: planning, tool use, memory, and adaptation
- Design effective prompts and workflows for agent systems
- Test and debug agent behavior systematically
- Choose the right framework for different use cases

---

## 🛠️ Agent Development Framework Landscape

### **Framework Comparison Overview**

| Framework | Strengths | Best For | Learning Curve |
|-----------|-----------|----------|----------------|
| **LangChain** | Mature ecosystem, extensive tool integration | Rapid prototyping, research projects | Medium |
| **CrewAI** | Multi-agent collaboration, role-based design | Team-based workflows, specialized agents | Low |
| **Semantic Kernel** | Enterprise integration, Microsoft ecosystem | Business applications, .NET environments | Medium |
| **AutoGen** | Advanced multi-agent conversation | Research, complex agent interactions | High |

### **Selection Criteria**

```text
Simple Single Agent ────► LangChain
     │
Multi-Agent Team ────► CrewAI
     │
Enterprise Integration ────► Semantic Kernel
     │
Research/Experimental ────► AutoGen
```

---

## 🔧 Building Your First Agent with LangChain

### **Environment Setup**

```bash
# Install required packages
pip install langchain langchain-openai langchain-community
pip install python-dotenv requests beautifulsoup4

# Create environment file
echo "OPENAI_API_KEY=your_api_key_here" > .env
```

### **Basic Agent Implementation**

```python
import os
from dotenv import load_dotenv
from langchain.agents import AgentType, initialize_agent, Tool
from langchain.llms import OpenAI
from langchain.memory import ConversationBufferMemory
from langchain.tools import DuckDuckGoSearchRun
import requests

# Load environment variables
load_dotenv()

class ResearchAgent:
    def __init__(self):
        # Initialize LLM
        self.llm = OpenAI(
            temperature=0.7,
            openai_api_key=os.getenv("OPENAI_API_KEY")
        )
        
        # Initialize memory
        self.memory = ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True
        )
        
        # Define tools
        self.tools = [
            Tool(
                name="web_search",
                description="Search the web for current information",
                func=DuckDuckGoSearchRun().run
            ),
            Tool(
                name="url_fetch",
                description="Fetch content from a specific URL",
                func=self.fetch_url_content
            ),
            Tool(
                name="summarize",
                description="Summarize long text content",
                func=self.summarize_content
            )
        ]
        
        # Initialize agent
        self.agent = initialize_agent(
            tools=self.tools,
            llm=self.llm,
            agent=AgentType.CONVERSATIONAL_REACT_DESCRIPTION,
            memory=self.memory,
            verbose=True,
            max_iterations=5
        )
    
    def fetch_url_content(self, url: str) -> str:
        """Fetch and clean content from a URL"""
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Extract text content
            text = soup.get_text()
            
            # Clean and truncate
            lines = [line.strip() for line in text.splitlines()]
            clean_text = ' '.join([line for line in lines if line])
            
            # Truncate to reasonable length
            return clean_text[:5000] + "..." if len(clean_text) > 5000 else clean_text
            
        except Exception as e:
            return f"Error fetching URL: {str(e)}"
    
    def summarize_content(self, text: str) -> str:
        """Summarize long content"""
        if len(text) < 500:
            return text
        
        summary_prompt = f"""
        Please provide a concise summary of the following text,
        highlighting the key points and main conclusions:
        
        {text[:3000]}
        """
        
        return self.llm(summary_prompt)
    
    def research(self, topic: str) -> str:
        """Conduct research on a given topic"""
        research_prompt = f"""
        You are a research assistant. Please research the following topic thoroughly:
        {topic}
        
        Your research should include:
        1. Current state and recent developments
        2. Key statistics and data points
        3. Expert opinions and analysis
        4. Future trends and implications
        
        Use the available tools to gather information from multiple sources.
        Provide a comprehensive summary with sources cited.
        """
        
        return self.agent.run(research_prompt)

# Usage example
if __name__ == "__main__":
    agent = ResearchAgent()
    result = agent.research("Impact of AI on software development productivity")
    print(result)
```

### **Enhanced Agent with Custom Tools**

```python
class AdvancedResearchAgent(ResearchAgent):
    def __init__(self):
        super().__init__()
        
        # Add specialized tools
        self.tools.extend([
            Tool(
                name="analyze_trends",
                description="Analyze trends in data or text",
                func=self.analyze_trends
            ),
            Tool(
                name="generate_report",
                description="Generate a formatted research report",
                func=self.generate_report
            ),
            Tool(
                name="fact_check",
                description="Verify facts and claims",
                func=self.fact_check
            )
        ])
        
        # Reinitialize agent with new tools
        self.agent = initialize_agent(
            tools=self.tools,
            llm=self.llm,
            agent=AgentType.CONVERSATIONAL_REACT_DESCRIPTION,
            memory=self.memory,
            verbose=True,
            max_iterations=8
        )
    
    def analyze_trends(self, data: str) -> str:
        """Analyze trends in the provided data"""
        analysis_prompt = f"""
        Analyze the following information for trends, patterns, and insights:
        {data}
        
        Identify:
        1. Key trends and patterns
        2. Growth rates or changes over time
        3. Significant correlations
        4. Potential future implications
        """
        
        return self.llm(analysis_prompt)
    
    def generate_report(self, research_data: str) -> str:
        """Generate a formatted research report"""
        report_prompt = f"""
        Based on the research data below, create a well-structured report:
        
        {research_data}
        
        Format the report with:
        - Executive Summary
        - Key Findings
        - Detailed Analysis
        - Conclusions and Recommendations
        - Sources and References
        """
        
        return self.llm(report_prompt)
    
    def fact_check(self, claim: str) -> str:
        """Verify facts and claims"""
        # Use web search to verify claims
        search_query = f"verify fact check: {claim}"
        search_results = DuckDuckGoSearchRun().run(search_query)
        
        verification_prompt = f"""
        Fact-check the following claim using the search results:
        
        Claim: {claim}
        
        Search Results: {search_results}
        
        Provide:
        1. Verification status (True/False/Partially True/Unclear)
        2. Supporting evidence
        3. Any contradictory information
        4. Confidence level in the assessment
        """
        
        return self.llm(verification_prompt)
```

---

## 👥 Multi-Agent Development with CrewAI

### **CrewAI Setup and Concepts**

```bash
# Install CrewAI
pip install crewai crewai-tools
```

### **Multi-Agent Team Implementation**

```python
from crewai import Agent, Task, Crew, Process
from crewai_tools import SerperDevTool, ScrapeWebsiteTool
import os

class MarketResearchCrew:
    def __init__(self):
        # Initialize tools
        self.search_tool = SerperDevTool()
        self.scrape_tool = ScrapeWebsiteTool()
        
        # Create specialized agents
        self.researcher = Agent(
            role="Market Researcher",
            goal="Gather comprehensive market data and insights",
            backstory="""You are an experienced market researcher with a keen eye
            for identifying trends, opportunities, and market dynamics. You excel
            at gathering data from multiple sources and synthesizing insights.""",
            tools=[self.search_tool, self.scrape_tool],
            verbose=True,
            allow_delegation=False
        )
        
        self.analyst = Agent(
            role="Data Analyst",
            goal="Analyze market data and identify patterns and trends",
            backstory="""You are a skilled data analyst who specializes in
            interpreting market data, identifying trends, and providing
            actionable insights for business decisions.""",
            tools=[],
            verbose=True,
            allow_delegation=False
        )
        
        self.strategist = Agent(
            role="Business Strategist",
            goal="Develop strategic recommendations based on market analysis",
            backstory="""You are a senior business strategist with extensive
            experience in translating market insights into actionable business
            strategies and recommendations.""",
            tools=[],
            verbose=True,
            allow_delegation=False
        )
        
        self.writer = Agent(
            role="Report Writer",
            goal="Create comprehensive and well-structured market reports",
            backstory="""You are a professional business writer who specializes
            in creating clear, compelling, and actionable market research reports
            for executive audiences.""",
            tools=[],
            verbose=True,
            allow_delegation=False
        )
    
    def analyze_market(self, market_topic: str) -> str:
        # Define tasks for each agent
        research_task = Task(
            description=f"""
            Conduct comprehensive market research on: {market_topic}
            
            Your research should cover:
            - Market size and growth trends
            - Key players and competitive landscape
            - Recent developments and news
            - Customer segments and demographics
            - Regulatory environment and challenges
            
            Gather information from multiple reliable sources.
            """,
            agent=self.researcher,
            expected_output="Detailed market research findings with sources"
        )
        
        analysis_task = Task(
            description="""
            Analyze the market research data and identify:
            - Key trends and patterns
            - Growth opportunities
            - Potential threats and challenges
            - Market gaps and unmet needs
            - Competitive advantages and weaknesses
            
            Provide quantitative insights where possible.
            """,
            agent=self.analyst,
            expected_output="Comprehensive market analysis with key insights",
            context=[research_task]
        )
        
        strategy_task = Task(
            description="""
            Based on the market analysis, develop strategic recommendations:
            - Market entry strategies
            - Positioning opportunities
            - Partnership recommendations
            - Investment priorities
            - Risk mitigation strategies
            
            Focus on actionable recommendations with clear rationale.
            """,
            agent=self.strategist,
            expected_output="Strategic recommendations with implementation guidance",
            context=[research_task, analysis_task]
        )
        
        report_task = Task(
            description="""
            Create a comprehensive market research report that includes:
            - Executive Summary
            - Market Overview
            - Key Findings and Analysis
            - Strategic Recommendations
            - Implementation Roadmap
            - Risk Assessment
            
            The report should be professional, well-structured, and actionable.
            """,
            agent=self.writer,
            expected_output="Professional market research report",
            context=[research_task, analysis_task, strategy_task]
        )
        
        # Create and run the crew
        crew = Crew(
            agents=[self.researcher, self.analyst, self.strategist, self.writer],
            tasks=[research_task, analysis_task, strategy_task, report_task],
            process=Process.sequential,
            verbose=True
        )
        
        result = crew.kickoff()
        return result

# Usage example
if __name__ == "__main__":
    crew = MarketResearchCrew()
    report = crew.analyze_market("Electric Vehicle Charging Infrastructure")
    print(report)
```

### **Collaborative Agent Workflows**

```python
class ProductDevelopmentCrew:
    def __init__(self):
        self.market_researcher = Agent(
            role="Market Researcher",
            goal="Identify market needs and opportunities",
            backstory="Expert in understanding customer needs and market gaps",
            tools=[SerperDevTool()],
            verbose=True
        )
        
        self.product_designer = Agent(
            role="Product Designer",
            goal="Design innovative product concepts",
            backstory="Creative designer focused on user experience and innovation",
            tools=[],
            verbose=True
        )
        
        self.technical_architect = Agent(
            role="Technical Architect",
            goal="Assess technical feasibility and requirements",
            backstory="Senior architect with deep technical expertise",
            tools=[],
            verbose=True
        )
        
        self.business_analyst = Agent(
            role="Business Analyst",
            goal="Evaluate business viability and create business case",
            backstory="Experienced in business modeling and financial analysis",
            tools=[],
            verbose=True
        )
    
    def develop_product_concept(self, product_idea: str) -> str:
        # Collaborative workflow
        market_research = Task(
            description=f"Research market opportunity for: {product_idea}",
            agent=self.market_researcher,
            expected_output="Market opportunity analysis"
        )
        
        product_design = Task(
            description="Design product concept based on market research",
            agent=self.product_designer,
            expected_output="Product concept and feature specifications",
            context=[market_research]
        )
        
        technical_assessment = Task(
            description="Assess technical feasibility of the product concept",
            agent=self.technical_architect,
            expected_output="Technical feasibility assessment",
            context=[product_design]
        )
        
        business_case = Task(
            description="Create business case and financial projections",
            agent=self.business_analyst,
            expected_output="Complete business case with financial model",
            context=[market_research, product_design, technical_assessment]
        )
        
        crew = Crew(
            agents=[self.market_researcher, self.product_designer, 
                   self.technical_architect, self.business_analyst],
            tasks=[market_research, product_design, technical_assessment, business_case],
            process=Process.sequential,
            verbose=True
        )
        
        return crew.kickoff()
```

---

## 🏢 Enterprise Agent Development with Semantic Kernel

### **Semantic Kernel Setup**

```bash
# Install Semantic Kernel for Python
pip install semantic-kernel
```

### **Enterprise-Grade Agent Implementation**

```python
import semantic_kernel as sk
from semantic_kernel.connectors.ai.open_ai import OpenAIChatCompletion
from semantic_kernel.core_plugins.text_plugin import TextPlugin
from semantic_kernel.core_plugins.web_search_engine_plugin import WebSearchEnginePlugin
import asyncio

class EnterpriseAgent:
    def __init__(self):
        # Initialize kernel
        self.kernel = sk.Kernel()
        
        # Add AI service
        self.kernel.add_service(
            OpenAIChatCompletion(
                ai_model_id="gpt-3.5-turbo",
                api_key=os.getenv("OPENAI_API_KEY")
            )
        )
        
        # Add plugins
        self.kernel.add_plugin(TextPlugin(), "text")
        
        # Custom business plugin
        self.add_business_plugins()
    
    def add_business_plugins(self):
        """Add custom business-specific plugins"""
        
        @self.kernel.function(
            description="Analyze business metrics and KPIs",
            name="analyze_metrics"
        )
        def analyze_business_metrics(metrics_data: str) -> str:
            """Analyze business metrics and provide insights"""
            return f"Analysis of metrics: {metrics_data}"
        
        @self.kernel.function(
            description="Generate business recommendations",
            name="generate_recommendations"
        )
        def generate_recommendations(analysis: str) -> str:
            """Generate actionable business recommendations"""
            return f"Recommendations based on: {analysis}"
        
        @self.kernel.function(
            description="Create executive summary",
            name="create_summary"
        )
        def create_executive_summary(content: str) -> str:
            """Create executive-level summary"""
            return f"Executive summary of: {content}"
    
    async def process_business_request(self, request: str) -> str:
        """Process complex business requests using multiple functions"""
        
        # Create a plan for the request
        planner = self.kernel.create_plan(request)
        
        # Execute the plan
        result = await planner.invoke_async()
        
        return str(result)
    
    async def automated_reporting(self, data_source: str) -> str:
        """Generate automated business reports"""
        
        # Define workflow
        workflow = """
        1. Extract key metrics from {{$data_source}}
        2. Analyze trends and patterns
        3. Generate insights and recommendations
        4. Create executive summary
        5. Format as professional report
        """
        
        # Create semantic function
        report_function = self.kernel.create_semantic_function(
            workflow,
            function_name="generate_report",
            description="Generate comprehensive business report"
        )
        
        # Execute workflow
        result = await report_function.invoke_async(data_source=data_source)
        
        return str(result)

# Usage in enterprise context
class BusinessIntelligenceAgent(EnterpriseAgent):
    def __init__(self):
        super().__init__()
        self.add_bi_specific_functions()
    
    def add_bi_specific_functions(self):
        """Add BI-specific capabilities"""
        
        @self.kernel.function(
            description="Connect to business databases",
            name="query_database"
        )
        def query_business_database(query: str) -> str:
            """Execute business intelligence queries"""
            # Implement secure database connection
            return f"Query results for: {query}"
        
        @self.kernel.function(
            description="Generate visualizations",
            name="create_charts"
        )
        def create_data_visualizations(data: str) -> str:
            """Create charts and visualizations"""
            return f"Visualization created for: {data}"
    
    async def generate_bi_report(self, business_question: str) -> str:
        """Generate comprehensive BI report"""
        
        bi_workflow = f"""
        Business Question: {business_question}
        
        Process:
        1. Identify relevant data sources
        2. Query necessary databases
        3. Analyze data trends
        4. Create visualizations
        5. Generate insights
        6. Provide recommendations
        7. Format as executive report
        
        Output comprehensive business intelligence report.
        """
        
        bi_function = self.kernel.create_semantic_function(
            bi_workflow,
            function_name="bi_analysis",
            description="Comprehensive BI analysis"
        )
        
        result = await bi_function.invoke_async()
        return str(result)
```

---

## 🧪 Agent Testing and Debugging

### **Testing Framework**

```python
import unittest
from unittest.mock import Mock, patch
import json

class AgentTestFramework:
    def __init__(self, agent):
        self.agent = agent
        self.test_cases = []
        self.results = []
    
    def add_test_case(self, name: str, input_data: dict, expected_behavior: str):
        """Add a test case for the agent"""
        self.test_cases.append({
            'name': name,
            'input': input_data,
            'expected': expected_behavior
        })
    
    def run_tests(self):
        """Execute all test cases"""
        for test_case in self.test_cases:
            try:
                result = self.agent.execute(test_case['input'])
                
                evaluation = self.evaluate_result(
                    result=result,
                    expected=test_case['expected'],
                    test_name=test_case['name']
                )
                
                self.results.append({
                    'test': test_case['name'],
                    'result': result,
                    'evaluation': evaluation,
                    'passed': evaluation['score'] > 0.7
                })
                
            except Exception as e:
                self.results.append({
                    'test': test_case['name'],
                    'result': None,
                    'evaluation': {'error': str(e)},
                    'passed': False
                })
    
    def evaluate_result(self, result: str, expected: str, test_name: str) -> dict:
        """Evaluate agent result against expected behavior"""
        
        evaluation_prompt = f"""
        Evaluate the agent's performance on this test:
        
        Test: {test_name}
        Expected Behavior: {expected}
        Actual Result: {result}
        
        Rate the performance on:
        1. Accuracy (0-1): How correct is the result?
        2. Completeness (0-1): How complete is the response?
        3. Relevance (0-1): How relevant to the request?
        4. Quality (0-1): Overall quality of the output?
        
        Provide scores and brief feedback.
        """
        
        # Use LLM to evaluate (simplified for example)
        evaluation = {
            'accuracy': 0.8,
            'completeness': 0.7,
            'relevance': 0.9,
            'quality': 0.8,
            'score': 0.8,
            'feedback': 'Good performance with minor areas for improvement'
        }
        
        return evaluation
    
    def generate_report(self) -> str:
        """Generate test report"""
        passed = sum(1 for r in self.results if r['passed'])
        total = len(self.results)
        
        report = f"""
        Agent Test Report
        =================
        
        Total Tests: {total}
        Passed: {passed}
        Failed: {total - passed}
        Success Rate: {passed/total*100:.1f}%
        
        Detailed Results:
        """
        
        for result in self.results:
            status = "PASS" if result['passed'] else "FAIL"
            report += f"\n{result['test']}: {status}"
            if 'evaluation' in result and 'feedback' in result['evaluation']:
                report += f"\n  Feedback: {result['evaluation']['feedback']}"
        
        return report

# Example usage
def test_research_agent():
    agent = ResearchAgent()
    test_framework = AgentTestFramework(agent)
    
    # Add test cases
    test_framework.add_test_case(
        name="Simple Research Query",
        input_data={"topic": "Python programming best practices"},
        expected_behavior="Provide comprehensive overview with current best practices"
    )
    
    test_framework.add_test_case(
        name="Complex Multi-Step Research",
        input_data={"topic": "AI impact on software development productivity metrics"},
        expected_behavior="Gather data from multiple sources, analyze trends, provide insights"
    )
    
    # Run tests
    test_framework.run_tests()
    
    # Generate report
    report = test_framework.generate_report()
    print(report)
    
    return test_framework.results
```

### **Debugging Tools and Techniques**

```python
class AgentDebugger:
    def __init__(self, agent):
        self.agent = agent
        self.debug_logs = []
        self.performance_metrics = {}
    
    def log_step(self, step_type: str, content: str, metadata: dict = None):
        """Log agent execution steps for debugging"""
        import time
        
        log_entry = {
            'timestamp': time.time(),
            'step_type': step_type,
            'content': content,
            'metadata': metadata or {}
        }
        
        self.debug_logs.append(log_entry)
        print(f"[{step_type}] {content}")
    
    def measure_performance(self, operation_name: str):
        """Decorator to measure operation performance"""
        def decorator(func):
            def wrapper(*args, **kwargs):
                import time
                start_time = time.time()
                
                try:
                    result = func(*args, **kwargs)
                    success = True
                    error = None
                except Exception as e:
                    result = None
                    success = False
                    error = str(e)
                
                end_time = time.time()
                duration = end_time - start_time
                
                self.performance_metrics[operation_name] = {
                    'duration': duration,
                    'success': success,
                    'error': error
                }
                
                self.log_step(
                    step_type="PERFORMANCE",
                    content=f"{operation_name}: {duration:.2f}s",
                    metadata={'success': success, 'error': error}
                )
                
                return result
            return wrapper
        return decorator
    
    def analyze_conversation_flow(self):
        """Analyze the flow of agent conversation"""
        thoughts = [log for log in self.debug_logs if 'thought' in log['step_type'].lower()]
        actions = [log for log in self.debug_logs if 'action' in log['step_type'].lower()]
        
        analysis = {
            'total_thoughts': len(thoughts),
            'total_actions': len(actions),
            'thought_to_action_ratio': len(thoughts) / max(len(actions), 1),
            'average_thought_length': sum(len(t['content']) for t in thoughts) / max(len(thoughts), 1),
            'action_types': list(set(a.get('metadata', {}).get('action_type') for a in actions))
        }
        
        return analysis
    
    def export_debug_session(self, filename: str):
        """Export debug session for analysis"""
        debug_data = {
            'logs': self.debug_logs,
            'performance': self.performance_metrics,
            'analysis': self.analyze_conversation_flow()
        }
        
        with open(filename, 'w') as f:
            json.dump(debug_data, f, indent=2)
        
        print(f"Debug session exported to {filename}")
```

---

## 🔗 Related Topics

### **Prerequisites**

- **[01_AI-Agent-Fundamentals.md](01_AI-Agent-Fundamentals.md)** - Core agent concepts and capabilities
- **[02_Agent-Architectures-Patterns.md](02_Agent-Architectures-Patterns.md)** - Architectural patterns and design approaches

### **Related**

- **[04_Multi-Agent-Systems.md](04_Multi-Agent-Systems.md)** - Scaling to multiple collaborative agents
- **[../05_MCP-Servers/01_MCP-Fundamentals.md](../05_MCP-Servers/01_MCP-Fundamentals.md)** - Tool integration protocols

### **Advanced**

- **[05_Agentic-AI-Advanced-Systems.md](05_Agentic-AI-Advanced-Systems.md)** - Advanced reasoning and planning
- **[06_Agent-Production-Deployment.md](06_Agent-Production-Deployment.md)** - Production deployment and monitoring

---

## 🚀 Next Steps

1. **Framework Selection**: Choose the framework that best fits your use case and experience level
2. **Prototype Development**: Build a simple agent using the examples as starting points
3. **Tool Integration**: Add domain-specific tools and capabilities to your agent
4. **Testing Implementation**: Set up systematic testing for your agent's behavior
5. **Performance Optimization**: Profile and optimize your agent's performance
6. **Multi-Agent Exploration**: Experiment with multi-agent collaboration patterns

---

**💡 Key Takeaway**: Practical agent development requires balancing framework capabilities with your specific needs. Start simple, test thoroughly, and iterate based on real-world performance. The framework you choose should support your long-term goals while enabling rapid prototyping and experimentation.
