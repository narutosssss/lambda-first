using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Xunit;
using Amazon.Lambda.Core;
using Amazon.Lambda.TestUtilities;

using aws_lambda_function;
using Newtonsoft.Json;
using Amazon.Lambda.APIGatewayEvents;
using System.IO;

namespace aws_lambda_function.Tests
{
    public class FunctionTest
    {
        [Fact]
        public void TestFunctionMethod()
        {
            string expected = "{\"message\":\"Hello, iFew\"}";

            var requestString = File.ReadAllText("./SampleRequests/TestGetMethod.json");

            TestLambdaContext context;
            APIGatewayProxyRequest request;
            APIGatewayProxyResponse hello_result;

            Function function = new Function();

            request = JsonConvert.DeserializeObject<APIGatewayProxyRequest>(requestString);
            context = new TestLambdaContext();
            hello_result = function.FunctionHandler(request, context);

            Assert.Equal(expected, hello_result.Body);
        }

        [Fact]
        public void TestHelloMethod()
        {
            string input = "iFew";
            string expected = "Hello, iFew";

            var function = new Function();
            string hello_result = function.Hello(input);

            Assert.Equal(expected, hello_result);
        }
    }
}
