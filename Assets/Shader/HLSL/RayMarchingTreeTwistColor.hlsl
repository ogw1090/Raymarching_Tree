//位置を受け取り，物体までの距離を計算する関数
//質点の距離関数"length(p)"から半径を引くと，球の距離関数が定義できる
float3 offset;
float k;
float3 color;
int num;

struct Distance
{
    float3 pos;
    float3 color;
};

//Capsule Line
float ln(float3 p, float3 a, float3 b, float R) 
{
    float r = dot(p - a, b - a) / dot(b - a, b - a);
    r = clamp(r, 0., 1.);
    p.x += 0.2 * sqrt(R) * smoothstep(1., 0., abs(r * 2. - 1.));
    return length(p - a - (b - a) * r) - R * (1.5 - 0.4 * r);
}

float2x2 ro(float a) 
{
    float s = sin(a), c = cos(a);
    return float2x2(c, -s, s, c);
}


float Branch(float3 p) 
{
    p -= offset;
    //rl: 枝のパラメータ
    //rl(枝半径、終点)
    float2 rl = float2(0.02, 0.25);
    float l = length(p) - 1e-2;

    for (int i = 1; i < num + 1; i++)
    {
        if (i <= 2)
        {
            float c = cos(k * p.y);
            float s = sin(k * p.y);
            float2x2 m = float2x2(c, -s, s, c);
            float2 q = mul(m, p.xz);
            p.x = q.x;
            p.z = q.y;
        }

        float c = 0.5 * PI + 0.2 * sin(0.5278 * _Time.y) + 0.8 * float(i) * (sin(0.1 * _Time.y) * (sin(0.1 * PI * _Time.y) + sin(0.333 * _Time.y) + 0.2 * sin(1.292 * _Time.y)));

        l = min(l, ln(p, float3(0, 0, 0), float3(0, rl.y, 0), rl.x));
        p.y -= rl.y;
        p.x = abs(p.x);
        p.xy = mul(p.xy, ro(-0.7));
        p.zx = mul(p.zx, ro(c));
        l = min(l, length(p) - 0.15 * sqrt(rl.x));
        //if ( i == 8)
        //{
        //    l = min(l, length(p) - 0.01 * sin(0.1 * PI * _Time.y));
        //}
        rl *= 0.65;
    }
    return l;
}

float Sphere(float3 p)
{
    p -= offset;
    //rl: 枝のパラメータ
    //rl(枝半径、終点)
    float2 rl = float2(0.02, 0.25);
    float l = length(p) - 1e-2;

    for (int i = 1; i < num + 1; i++)
    {
        if (i <= 2)
        {
            float c = cos(k * p.y);
            float s = sin(k * p.y);
            float2x2 m = float2x2(c, -s, s, c);
            float2 q = mul(m, p.xz);
            p.x = q.x;
            p.z = q.y;
        }

        float c = 0.5 * PI + 0.2 * sin(0.5278 * _Time.y) + 0.8 * float(i) * (sin(0.1 * _Time.y) * (sin(0.1 * PI * _Time.y) + sin(0.333 * _Time.y) + 0.2 * sin(1.292 * _Time.y)));

        l = min(l, ln(p, float3(0, 0, 0), float3(0, rl.y, 0), rl.x - 0.01f));
        p.y -= rl.y;
        p.x = abs(p.x);
        p.xy = mul(p.xy, ro(-0.7));
        p.zx = mul(p.zx, ro(c));
        l = min(l, length(p) - 0.10 * sqrt(rl.x));
        if (i == num)
        {
            //l = min(l, length(p) - 0.01 * sin(0.1 * PI * _Time.y));
            l = min(l, length(p) - 0.01);
        }
        rl *= 0.65;
    }
    return l;
}

float Map(float3 p)
{
    float b_dist = Branch(p);
    float s_dist = Sphere(p);

    if (b_dist < s_dist)
    {
        color = float3(1.0f, 1.0f, 1.0f);
        return b_dist;
    }
    return s_dist;
}


//法線を計算する
float3 CalcNormal(float3 p)
{
    //距離関数の勾配を取って正規化すると法線が計算できる
    float2 ep = float2(0, 0.001);
    return normalize(
        float3(
            Map(p + ep.yxx) - Map(p),
            Map(p + ep.xyx) - Map(p),
            Map(p + ep.xxy) - Map(p)
        )
    );
}

//マーチングループの本体
void RayMarchingTreeTwistColor_float
(
    float3 RayPosition,
    float3 RayDirection,
    float3 Offset,
    float Twist_k,
    float3 Color,
    out bool Hit,
    out float3 HitPosition,
    out float3 HitNormal,
    out float3 HitColor
)
{
    float3 pos = RayPosition;
    offset = Offset;
    k = Twist_k;
    color = Color;
    num = 8;

    //各ピクセルごとに64回のループをまわす
    for(int i = 0; i < 24; i ++)
    {
        //距離関数の分だけレイを進める
        float d = Map(pos);
        pos += d * RayDirection;

        //距離関数がある程度小さければ衝突している見なす
        if(d < 0.001)
        {
            Hit = true;
            HitPosition = pos;
            HitNormal = CalcNormal(pos);
            HitColor = color;
            return;
        }
    }
}