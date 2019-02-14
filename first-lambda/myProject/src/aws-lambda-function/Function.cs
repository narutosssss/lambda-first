using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

using Amazon.Lambda.Core;
using Amazon.Lambda.APIGatewayEvents;
using Newtonsoft.Json;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]
namespace aws_lambda_function
{
    public class Function
    {
        public APIGatewayProxyResponse FunctionHandler(APIGatewayProxyRequest request, ILambdaContext context)
        {
            string name = null;
            //request.QueryStringParameters["abc"]
            if (request.QueryStringParameters != null && request.QueryStringParameters.ContainsKey("name"))
                name = request.QueryStringParameters["name"];

            if (!String.IsNullOrEmpty(name))
            {
                //
                var data = new HelloModel {
                    message = Hello(name)
                };

                APIGatewayProxyResponse respond = new APIGatewayProxyResponse {
                    StatusCode = (int)HttpStatusCode.OK,
                    Headers = new Dictionary<string, string>
                    { 
                        { "Content-Type", "application/json" }, 
                        { "Access-Control-Allow-Origin", "*" } 
                    },
                    Body = JsonConvert.SerializeObject(data)
                };

                return respond;
            }

            return new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.NotFound
            };
        }

        public string Hello(string name)
        {
            return "Hello, " + name;
        }

    }
}
