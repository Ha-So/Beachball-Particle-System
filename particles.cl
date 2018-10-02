typedef float4 point;
typedef float4 vector;
typedef float4 color;
typedef float4 sphere;


vector
Bounce( vector in, vector n)
{
	vector out = in - n*(vector)( 2.*dot(in.xyz, n.xyz) );
	out.w = 0.;
	return out;
}

vector
BounceSphere( point p, vector v, sphere s)
{
	vector n;
	n.xyz = fast_normalize( p.xyz - s.xyz );
	n.w = 0.;
	return Bounce( v, n);
}


bool
IsInsideSphere( point p, sphere s )
{
	float r = fast_length( p.xyz - s.xyz );
	return  ( r < s.w );
}


kernel
void
Particle( global point *dPobj, global point *dP2obj, global vector *dVel, global color *dCobj, global point *dP3obj )
{
	const float4 G       = (float4) ( 0., -9.8, 0., 0. );
	const float  DT      = 0.11;
	const sphere Sphere1 = (sphere)( -100., -25000., 0.,  15000. );
	const sphere Sphere2 = (sphere)( -100., 800., 0.,  600. );
	const sphere Sphere3 = (sphere)( -100., -5000., 0.,  5000. );

	int gid = get_global_id( 0 );

	point  p = dPobj[gid];
	point  p2 = dP2obj[gid];
	point  p3 = dP3obj[gid];
	vector v = dVel[gid];
	color c = dCobj[gid];

	point  pp = p + v*DT + G*(point)( .5*DT*DT );
	point  pp2 = p2 + v*DT + G*(point)( .5*DT*DT );
	point  pp3 = p3 + v*DT + G*(point)( .5*DT*DT );
	vector vp = v + G*DT;
	color cp = c;
	if(vp.x > 0.0)
	{
		cp.x = cp.x + .1f;
	}
	else
	{
		cp.x = cp.x - .1f;
	}
	if(vp.y >  0.0)
	{
		cp.y = cp.y + .1f;
	}
	else
	{
		cp.y = cp.y - .1f;
	}
	if(vp.z >  0.0)
	{
		cp.z = cp.z + .1f;
	}
	else
	{
		cp.z = cp.z - .1f;
	}

	
	
	
	
	

	pp.w = 1.;
	pp2.w = 1.;
	pp3.w = 1.;
	vp.w = 0.;
	cp.w = 1.;
	
	

	if( IsInsideSphere( pp, Sphere1 ) )
	{
		vp = BounceSphere( p, v, Sphere1);
		pp = p + vp*DT + G*(point)( .5*DT*DT );
		
	}
	
	if( IsInsideSphere( pp2, Sphere2 ) )
	{
		vp = BounceSphere( p2, v, Sphere2);
		pp2 = p2 + vp*DT + G*(point)( .5*DT*DT );	
	}
	if(IsInsideSphere( pp3, Sphere3 ) )
	{
		vp = BounceSphere( p3, v, Sphere3);
		pp3 = p3 + vp*DT + G*(point)( .5*DT*DT );
	
	}
	

	
	

	dPobj[gid] = pp;
	dP2obj[gid] = pp2;
	dP3obj[gid] = pp3;
	dVel[gid]  = vp;
	dCobj[gid] = cp;
}
