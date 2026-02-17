public class EngineSystem {
    private DeterministicRng rng;
    public EngineSystem(DeterministicRng r) { rng = r; }

    public object GetData() {
        return new {
            temperature = rng.NextDouble(650, 750),
            rpm = rng.NextDouble(7000, 9000)
        };
    }
}
