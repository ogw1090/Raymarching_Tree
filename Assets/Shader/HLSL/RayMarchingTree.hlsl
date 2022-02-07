//位置を受け取り，物体までの距離を計算する関数
//質点の距離関数"length(p)"から半径を引くと，球の距離関数が定義できる
//float PI = 3.14159;
float3 offset;

//Capsule Line
float ln(float3 p, float3 a, float3 b, float R) {
    float r = dot(p - a, b - a) / dot(b - a, b - a);
    r = clamp(r, 0., 1.);
    p.x += 0.2 * sqrt(R) * smoothstep(1., 0., abs(r * 2. - 1.)) * cos(PI * (2. * _Time.y));
    return length(p - a - (b - a) * r) - R * (1.5 - 0.4 * r);
}

float2x2 ro(float a) {
    float s = sin(a), c = cos(a);
    return float2x2(c, -s, s, c);
}

float Dist(float3 p) {
    p -= offset;
    //rl: 枝のパラメータ
    //rl(枝半径、終点)
    float2 rl = float2(0.02, .25 + 0.01 * sin(PI * 4. * _Time.y));
    //float2 rl = float2(0.02, 0.25);
    float l = length(p) - 1e-2;

    //p.zx *= ro(.5 * _Time.y);
    p.zx = mul(p.zx, ro(.5 * _Time.y));

    for (int i = 1; i < 9; i++)
    {
        float a = 0.6 + 0.4 * sin(_Time.y) * sin(0.871 * _Time.y) + 0.05 * float(i) * sin(2. * _Time.y);
        float b = 0.0;
        float c = 0.5 * PI + 0.2 * sin(0.5278 * _Time.y) + 0.8 * float(i) * (sin(0.1 * _Time.y) * (sin(0.1 * PI * _Time.y) + sin(0.333 * _Time.y) + 0.2 * sin(1.292 * _Time.y)));

        l = min(l, ln(p, float3(0, 0, 0), float3(0, rl.y, 0), rl.x));
        p.y -= rl.y;
        p.x = abs(p.x);
        p.xy = mul(p.xy, ro(-a));
        //p.xy = mul(p.xy, ro(-a));
        //p.zy = mul(p.zy, ro(-0.3));
        p.zx = mul(p.zx, ro(c));
        l = min(l, length(p) - 0.15 * sqrt(rl.x));
        rl *= (0.7 + 0.015 * float(i) * (sin(_Time.y) + 0.1 * sin(4. * PI * _Time.y)));
        //rl *= 0.7;
    }



    //for (int i = 1; i < 5; i++) {

    //    l = min(l, ln(p, float3(0, 0, 0), float3(0, rl.y, 0), rl.x));

    //    //ToDo

    //    //p.y -= rl.y + offset;




    //    //p.xy = mul(p.xy, ro(0.2 * sin(3.1 * _Time.y + float(i)) + sin(0.222 * _Time.y) * (-0.1 * sin(0.4 * PI * _Time.y) + sin(0.543 * _Time.y) / max(float(i), 2.))));
    //    //p.xy = mul(p.xy, ro(0.2 * sin(3.1 * _Time.y + float(i)) + sin(0.222 * _Time.y) * (-0.1 * sin(0.4 * PI * _Time.y) + sin(0.543 * _Time.y) / max(float(i), 2.))));
    //    //p.xy = mul(p.xy, ro(0.1 * float(i)));
    //    p.xy = mul(p.xy, ro(0.7));

    //    p.x = abs(p.x);
    //    
    //    //p.xy = mul(p.xy, ro(0.6 + 0.4 * sin(_Time.y) * sin(0.871 * _Time.y) + 0.05 * float(i) * sin(2. * _Time.y)));
    //    //p.xy = mul(p.xy, ro(0.6 + 0.4 * sin(_Time.y) * sin(0.871 * _Time.y) + 0.05 * float(i) * sin(2. * _Time.y)));
    //    //p.xy = mul(p.xy, ro(0.3 * float(i)));
    //    //p.xy = mul(p.xy, ro(0.7));

    //    //p.zx = mul(p.zx, ro(0.5 * PI + 0.2 * sin(0.5278 * _Time.y) + 0.8 * float(i) * (sin(0.1 * _Time.y) * (sin(0.1 * PI * _Time.y) + sin(0.333 * _Time.y) + 0.2 * sin(1.292 * _Time.y)))));
    //    //

    //    //rl *= (0.7 + 0.015 * float(i) * (sin(_Time.y) + 0.1 * sin(4. * PI * _Time.y)));

    //    p.y -= rl.y + offset;

    //    rl *= 0.5;
    //    //min(枝,　節)
    //    //l = min(l, length(p) - 0.15 * sqrt(rl.x));
    //    l = min(l, length(p) - 0.01);
    //}

    return l;
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
void RayMarchingTree_float(
    float3 RayPosition,
    float3 RayDirection,
    float3 Offset,
    out bool Hit,
    out float3 HitPosition,
    out float3 HitNormal
)
{
    float3 pos = RayPosition;
    offset = Offset;

    //各ピクセルごとに64回のループをまわす
    for(int i = 0; i < 24; i ++)
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