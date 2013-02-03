package org.kaspernj.mirah.erb2mirah;

public class InstanceLoader
{
	public static <T> T load(Class<T> clazz) throws Exception{
		T instance = clazz.getConstructor( ).newInstance( );
		return instance;
	}
}
