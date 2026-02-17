public class ThreatSystem {
    private DeterministicRng rng;
    public ThreatSystem(DeterministicRng r) { rng = r; }

    public object[] GenerateThreats(int count) {
        var threats = new object[count];
        for (int i = 0; i < count; i++) {
            threats[i] = new {
                direction = rng.NextDouble(0, 360),
                distance = rng.NextDouble(1, 50)
            };
        }
        return threats;
    }
}
