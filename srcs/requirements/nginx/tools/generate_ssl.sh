server {

# The server listens for incoming connections on port 443, which is the default port for HTTPS traffic. The server listens for both IPv4 and IPv6 connections
	listen 443 ssl;
	listen [::]:443 ssl;

	server_name www.moabdels.42beirut.lb moabdels.42beirut.lb;

# The ssl_certificate and ssl_certificate_key directives specify the locations of the SSL/TLS certificate and private key, respectively, that will be used to encrypt the traffic. The ssl_protocols directive specifies the TLS protocols that the server should support.
	ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
	ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
	ssl_protocols TLSv1.3;

# The index directive specifies the default file that should be served when a client requests a directory on the server. The root directive specifies the root directory that should be used to search for files.
	index index.php;
	root /var/www/html;

# The location directive defines a block of configuration that applies to a specific location, which is specified using a regular expression. In this case, the regular expression ~ [^/]\\.php(/|$) matches any request that ends in .php and is not preceded by a / character.

	location ~ [^/]\\.php(/|$) {

# The try_files directive attempts to serve the requested file, and if it does not exist, it will return a 404 error.
        try_files $uri =404;

#The fastcgi_pass directive passes the request to a FastCGI server for processing.
        fastcgi_pass wordpress:9000;

	# The include directive includes a file with FastCGI parameters.
        include fastcgi_params;

#The fastcgi_param directive sets a FastCGI parameter. The SCRIPT_FILENAME parameter specifies the path to the PHP script that should be executed.
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}