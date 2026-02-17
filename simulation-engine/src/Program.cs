using StackExchange.Redis;
using System.Text.Json;
using System.Threading;

class Simulator {
    static void Main() {
        var redis = ConnectionMultiplexer.Connect("localhost:6379");
        var pub = redis.GetSubscriber();
        var db = redis.GetDatabase();

        var rng = new DeterministicRng(12345);
        var engine = new EngineSystem(rng);
        var threats = new ThreatSystem(rng);

        while (true) {
            var packet = new {
                position = new { lat = 33.64, lon = -84.42 },
                engine = engine.GetData(),
                threats = threats.GenerateThreats(10)
            };

            string json = JsonSerializer.Serialize(packet);
            db.HashSet("f35:state", new HashEntry[] { new HashEntry("latest", json) });
            pub.Publish("f35:realtime", json);

            Thread.Sleep(100); // 10 Hz update rate
        }
    }
}
