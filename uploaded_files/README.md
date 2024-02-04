# Run the backend

- Install Docker 
- Build the image with `sudo docker build -t my-backend`
- Run the container `sudo docker run -it -p 5000:5000 --name my-bb-2 my-backend`
- Go to `http://127.0.0.1:5000/docs` to get the interface of the API and test the endpoints.

Note: To try the transcription endpoint use the `lecture_example_project-short.mp3` (it's only 2 min long). 