//位置を受け取り，物体までの距離を計算する関数
//質点の距離関数"length(p)"から半径を引くと，球の距離関数が定義できる
float Dist(float3 p)
{
    return length(p) - 0.5;
}

//法線を計算する
float3 CalcNormal(float3 p)
{
    //距離関数の勾配を取って正規化すると法線が計算できる
    float2 ep = float2(0, 0.001);
    return normalize(
        float3(
            Dist(p + ep.yxx) - Dist(p),
            Dist(p + ep.xyx) - Dist(p),
            Dist(p + ep.xxy) - Dist(p)
        )
    );
}

//マーチングループの本体
void RayMarchingSample_float(
    float3 RayPosition,
    float3 RayDirection,
    out bool Hit,
    out float3 HitPosition,
    out float3 HitNormal
)
{
    float3 pos = RayPosition;

    //各ピクセルごとに64回のループをまわす
    for(int i = 0; i < 64; i ++)
    {
        //距離関数の分だけレイを進める
        float d = Dist(pos);
        pos += d * RayDirection;

        //距離関数がある程度小さければ衝突している見なす
        if(d < 0.001)
        {
            Hit = true;
            HitPosition = pos;
            HitNormal = CalcNormal(pos);
            return;
        }
    }
}