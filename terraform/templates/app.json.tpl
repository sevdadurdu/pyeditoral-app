[
  {
    "name": "pyeditoral-app",
    "image": "${docker_image_url_pyeditoral}",
    "essential": true,
    "cpu": 256,
    "memory": 1024,
    "portMappings": [
      {
        "containerPort": 8000,
        "protocol": "tcp"
      }
    ],
    "command": ["gunicorn", "-w", "3", "-b", ":8000", "PyEditorial.wsgi:application"],
    "environment": [
      {
        "name": "SQL_DATABASE",
        "value": "${rds_db_name}"
      },
      {
        "name": "SQL_USER",
        "value": "${rds_username}"
      },
      {
        "name": "SQL_PASSWORD",
        "value": "${rds_password}"
      },
      {
        "name": "SQL_HOST",
        "value": "${rds_hostname}"
      },
      {
        "name": "SQL_PORT",
        "value": "5432"
      },
      {
        "name": "DJANGO_ALLOWED_HOSTS",
        "value": "${allowed_hosts}"
      },
      {
        "name": "SECRET_KEY",
        "value": "${secret_key}"
      },
      {
        "name": "DEBUG",
        "value": "0"
      }
    ]
  },
  {
    "name": "nginx",
    "image": "${docker_image_url_nginx}",
    "essential": true,
    "cpu": 256,
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/var/www/html",
        "sourceVolume": "efs-volume"
      }
    ]
  }
]